module GyrEfiler
  class SendSubmissionJob < ApplicationJob
    def perform(submission)
      Dir.mktmpdir do |tempdir|
        submission.submission_bundle.open do |local_copy|
          happy_filename = File.join(tempdir, submission.submission_bundle.filename.to_s)
          FileUtils.mv(local_copy.path, happy_filename)
          begin
            result = GyrEfilerService.run_efiler_command("submit", happy_filename)
          rescue StandardError => e
            submission.transition_to!(:failed, error_message: e.inspect)
            raise
          end
          doc = Nokogiri::XML(result)
          if doc.css('SubmissionReceiptList SubmissionReceiptGrp SubmissionId').text.strip == submission.irs_submission_id
            submission.transition_to!(:transmitted, receipt: result)
          else
            submission.transition_to!(:failed, error_message: result)
          end
        end
      end
    end
  end
end
