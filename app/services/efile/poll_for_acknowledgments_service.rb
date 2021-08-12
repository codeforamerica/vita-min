module Efile
  class PollForAcknowledgmentsService
    def self.run
      ack_count = 0
      submission_ids = transmitted_submission_ids
      submission_ids.each_slice(100) do |submission_ids|
        ack_count = _handle_response(Efile::GyrEfilerService.run_efiler_command(Rails.application.config.efile_environment, "acks", *submission_ids))
      end
      DatadogApi.gauge("efile.poll_for_acks.requested", submission_ids.size)
      DatadogApi.gauge("efile.poll_for_acks.received", ack_count)
      DatadogApi.increment("efile.poll_for_acks")
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

        if status == "Rejected"
          EfileSubmission.find_by(irs_submission_id: irs_submission_id).transition_to!(:rejected, raw_response: raw_response)
        elsif status == "Accepted"
          EfileSubmission.find_by(irs_submission_id: irs_submission_id).transition_to!(:accepted, raw_response: raw_response)
        else
          raise StandardError.new("Submission acknowledgement has an unknown status: #{status} for submission ID #{irs_submission_id}")
        end
      end
      ack_count
    end
  end
end
