module Efile
  class PollForAcknowledgmentsService
    def self.run
      Efile::GyrEfilerService.with_lock(ActiveRecord::Base.connection) do |lock_acquired|
        unless lock_acquired
          DatadogApi.increment("efile.poll_for_acks.lock_unavailable")
          return
        end

        ack_count = 0
        submission_ids = transmitted_submission_ids
        submission_ids.each_slice(100) do |submission_ids|
          begin
            ack_count = _handle_response(Efile::GyrEfilerService.run_efiler_command(Rails.application.config.efile_environment, "acks", *submission_ids))
          rescue Efile::GyrEfilerService::RetryableError
            DatadogApi.increment("efile.poll_for_acks.retryable_error")
            return
          end
        end
        DatadogApi.gauge("efile.poll_for_acks.requested", submission_ids.size)
        DatadogApi.gauge("efile.poll_for_acks.received", ack_count)
        DatadogApi.increment("efile.poll_for_acks")
      end
    end

    def self.transmitted_submission_ids
      transmitted_submissions = EfileSubmission.in_state(:transmitted)
      transmitted_submissions.touch_all(:last_checked_for_ack_at)
      transmitted_submissions.pluck(:irs_submission_id)
    end

    def self._handle_response(response)
      doc = Nokogiri::XML(response)
      ack_count = 0

      doc.css('AcknowledgementList Acknowledgement').each do |ack|
        ack_count += 1
        irs_submission_id = ack.css("SubmissionId").text.strip
        status = ack.css("AcceptanceStatusTxt").text.strip
        raw_response = ack.to_xml
        submission = EfileSubmission.find_by(irs_submission_id: irs_submission_id)
        unless submission.present?
          raise StandardError.new("Submission acknowledgement for unknown submission id: #{status} for submission ID #{irs_submission_id}")
        end

        if submission.current_state == status.downcase
          Sentry.capture_message("Submission #{submission.id} was already in terminal state #{status.downcase}. Duplicate acknowledgement?")
          next
        end

        if status == "Rejected"
          submission.transition_to(:rejected, raw_response: raw_response)
        elsif status == "Accepted"
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
