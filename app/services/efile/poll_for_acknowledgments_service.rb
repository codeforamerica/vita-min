module Efile
  class PollForAcknowledgmentsService
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
      state_submissions.touch_all(:last_checked_for_ack_at)
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

        if status == "Rejected"
          submission.transition_to(:rejected, raw_response: raw_response)
        elsif status == "Accepted" || status == "A"
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

      doc.css('StatusRecordGrp').each do |status_record_group|
        status_updates += 1
        irs_submission_id = status_record_group.css("SubmissionId").text.strip
        status = status_record_group.css('SubmissionStatusTxt').text.strip
        raw_response = status_record_group.to_xml
        submission = EfileSubmission.find_by(irs_submission_id: irs_submission_id)

        if ["Received",
            "Ready for Pickup",
            "Ready for Pick-Up",
            "Sent to State",
            "Received by State"].include?(status)
          # no action required - the IRS are still working on it
          submission.transition_to(:transmitted, raw_response: raw_response)
        elsif ["Acknowledgement Received from State", "Acknowledgement Retrieved", "Notified"].include(status)
          unless status == "Acknowledgement Received from State"
            Rails.logger.warn("Retrieved status for submission #{submission.id} that should already be in ready_for_ack state")
          end
          submission.transition_to(:ready_for_ack, raw_response: raw_response)
        else
          submission.transition_to(:failed, raw_response: raw_response)
        end
      end

      status_updates
    end
  end
end
