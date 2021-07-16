module Efile
  class PollForAcknowledgmentsService
    def self.run
      transmitted_submissions = EfileSubmission.in_state(:transmitted).limit(100)
      response = Efile::GyrEfilerService.run_efiler_command("acks", *transmitted_submissions.pluck(:irs_submission_id))
      doc = Nokogiri::XML(response)
      doc.css('AcknowledgementList Acknowledgement').each do |ack|
        irs_submission_id = ack.css("SubmissionId").text.strip
        errors_found = ack.css("ValidationErrorList").attr('errorCnt') != "0"
        raise StandardError.new("for now we always expect errors in acknowledgements, so this is weird") unless errors_found

        EfileSubmission.find_by(irs_submission_id: irs_submission_id).transition_to!(:rejected)
      end
    end
  end
end