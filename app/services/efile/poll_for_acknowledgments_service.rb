module Efile
  class PollForAcknowledgmentsService
    def self.run
      transmitted_submissions = EfileSubmission.in_state(:transmitted).limit(100)
      response = Efile::GyrEfilerService.run_efiler_command(Rails.application.config.efile_environment, "acks", *transmitted_submissions.pluck(:irs_submission_id))
      doc = Nokogiri::XML(response)
      doc.css('AcknowledgementList Acknowledgement').each do |ack|
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
    end
  end
end
