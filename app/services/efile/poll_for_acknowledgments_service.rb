
StatusRecordGroup = Struct.new(:irs_submission_id, :state, :xml)

module Efile
  class PollForAcknowledgmentsService
    TRANSMITTED_STATUSES = ["Received", "Ready for Pickup", "Ready for Pick-Up", "Sent to State", "Received by State"]
    READY_FOR_ACK_STATUSES = ["Denied by IRS", "Acknowledgement Received from State", "Acknowledgement Retrieved", "Notified"]

    def self.run
      Efile::GyrEfilerService.with_lock(ActiveRecord::Base.connection) do |lock_acquired|
        unless lock_acquired
          DatadogApi.increment("efile.poll_for_acks.lock_unavailable")
          return
        end

        state_submission_ids = transmitted_state_submission_ids
        poll(state_submission_ids, "submissions-status")

        submission_ids = ready_for_ack_submission_ids
        poll(submission_ids, "acks")
      end
    end

    def self.poll(submission_ids, endpoint)
      ack_count = 0
      dd_tag = endpoint.gsub("-", "_")
      submission_ids.each_slice(100) do |submission_ids|
        begin
          response = Efile::GyrEfilerService.run_efiler_command(Rails.application.config.efile_environment, endpoint, *submission_ids)
          if endpoint == 'acks'
            ack_count = _handle_ack_response(response)
          elsif endpoint == 'submissions-status'
            ack_count = _handle_submission_status_response(response)
          end
        rescue Efile::GyrEfilerService::RetryableError
          DatadogApi.increment("efile.poll_for_#{dd_tag}.retryable_error")
          return
        end
      end
      DatadogApi.gauge("efile.poll_for_#{dd_tag}.requested", submission_ids.size)
      DatadogApi.gauge("efile.poll_for_#{dd_tag}.received", ack_count)
      DatadogApi.increment("efile.poll_for_#{dd_tag}")
    end

    def self.ready_for_ack_submission_ids
      transmitted_submissions = EfileSubmission.in_state(:ready_for_ack)
      transmitted_submissions.touch_all(:last_checked_for_ack_at)
      transmitted_submissions.pluck(:irs_submission_id)
    end

    def self.transmitted_submission_ids
      transmitted_submissions = EfileSubmission.in_state(:transmitted).where.not(tax_return: nil).or(
        EfileSubmission.in_state(:ready_for_ack)
      )
      transmitted_submissions.touch_all(:last_checked_for_ack_at)
      transmitted_submissions.pluck(:irs_submission_id)
    end

    def self.transmitted_state_submission_ids
      transmitted_submissions = EfileSubmission.in_state(:transmitted)
      state_submissions = transmitted_submissions.for_state_filing
      state_submissions.pluck(:irs_submission_id)
    end

    def self._handle_ack_response(response)
      doc = Nokogiri::XML(response)
      ack_count = 0

      doc.css('AcknowledgementList Acknowledgement').each do |ack|
        ack_count += 1
        irs_submission_id = ack.css("SubmissionId").text.strip
        status = ack.css("AcceptanceStatusTxt").text.strip
        raw_response = ack.to_xml
        submission = EfileSubmission.find_by(irs_submission_id: irs_submission_id)

        unless submission.present?
          Sentry.capture_message("Submission acknowledgement for unfindable submission id: #{status} for IRS submission ID #{irs_submission_id}")
          next
        end

        if submission.current_state == status.downcase
          Sentry.capture_message("Submission #{submission.id} / #{irs_submission_id} was already in terminal state #{status.downcase}. Duplicate acknowledgement?")
          next
        end

        if ["Rejected", "Denied by IRS"].include?(status)
          submission.transition_to(:rejected, raw_response: raw_response)
        elsif ["Accepted", "A"].include?(status)
          submission.transition_to(:accepted, raw_response: raw_response)
        elsif status == "Exception"
          submission.transition_to(:accepted, raw_response: raw_response, imperfect_return_acceptance: true)
        else
          submission.transition_to(:failed, raw_response: raw_response)
        end
      end
      ack_count
    end

    def self._handle_submission_status_response(response)
      doc = Nokogiri::XML(response)
      status_updates = 0
      groups_by_irs_submission_id = group_status_records_by_submission_id(doc)
      submissions = EfileSubmission.where(irs_submission_id: groups_by_irs_submission_id.keys)
      submissions.each do |submission|
        status_updates += 1
        xml_node = groups_by_irs_submission_id[submission.irs_submission_id]
        status = xml_node.css('SubmissionStatusTxt').text.strip
        new_state = status_to_state(status)
        submission.transition_to(new_state, raw_response: xml_node.to_xml)
      end

      status_updates
    end

    def self.group_status_records_by_submission_id(doc)
      # The service returns multiple status records for the each submission id. It looks like they are in reverse
      # chronological order (But are not properly date stamped), so we grab the first ones.
      doc.css('StatusRecordGrp').each_with_object({}) do |xml, groups_by_irs_submission_id|
        irs_submission_id = xml.css("SubmissionId").text.strip
        unless groups_by_irs_submission_id[irs_submission_id]
          groups_by_irs_submission_id[irs_submission_id] = xml
        end
      end
    end

    def self.status_to_state(status)
      if TRANSMITTED_STATUSES.include?(status)
        # no action required - the IRS are still working on it
        :transmitted
      elsif READY_FOR_ACK_STATUSES.include?(status)
        :ready_for_ack
      else
        :failed
      end
    end
  end
end
