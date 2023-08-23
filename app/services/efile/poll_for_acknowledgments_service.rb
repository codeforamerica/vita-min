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
        submission_ids = transmitted_submission_ids
        poll(submission_ids, "acks")
      end
    end

    def self.poll(submission_ids, endpoint)
      ack_count = 0
      dd_tag = endpoint.gsub("-", "_")
      submission_ids.each_slice(100) do |submission_ids|
        begin
          response = Efile::GyrEfilerService.run_efiler_command(Rails.application.config.efile_environment, endpoint, *submission_ids)
          ack_count = _handle_response(response, endpoint)
        rescue Efile::GyrEfilerService::RetryableError
          DatadogApi.increment("efile.poll_for_#{dd_tag}.retryable_error")
          return
        end
      end
      DatadogApi.gauge("efile.poll_for_#{dd_tag}.requested", submission_ids.size)
      DatadogApi.gauge("efile.poll_for_#{dd_tag}.received", ack_count)
      DatadogApi.increment("efile.poll_for_#{dd_tag}")
    end

    def self.transmitted_submission_ids
      # TODO: is there a better way to do this query?
      transmitted_submissions = EfileSubmission.in_state(:transmitted).where.not(tax_return: nil)
      transmitted_submissions.touch_all(:last_checked_for_ack_at)
      transmitted_submissions.pluck(:irs_submission_id)
    end

    # TODO: make this less redundant with transmitted_submission_ids?
    def self.transmitted_state_submission_ids
      transmitted_submissions = EfileSubmission.in_state(:transmitted)
      # GARBAGE
      state_submissions = transmitted_submissions.includes(:data_source).select do |submission|
        submission.data_source.class == StateFileNyIntake || submission.data_source.class == StateFileAzIntake
      end
      state_submissions.pluck(:irs_submission_id)
    end

    def self._handle_response(response, endpoint = "acks")
      doc = Nokogiri::XML(response)
      ack_count = 0

      node = endpoint == "acks" ? 'AcknowledgementList Acknowledgement' : 'Acknowledgement'
      doc.css(node).each do |ack|
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
  end
end
