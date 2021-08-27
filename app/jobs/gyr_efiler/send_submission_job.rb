module GyrEfiler
  class SendSubmissionJob < ApplicationJob
    def perform(submission)
      Efile::GyrEfilerService.with_lock(ActiveRecord::Base.connection) do |lock_acquired|
        unless lock_acquired
          submission.retry_send_submission
          return
        end

        Dir.mktmpdir do |tempdir|
          submission.submission_bundle.open do |local_copy|
            happy_filename = File.join(tempdir, submission.submission_bundle.filename.to_s)
            FileUtils.mv(local_copy.path, happy_filename)
            begin
              result = Efile::GyrEfilerService.run_efiler_command(Rails.application.config.efile_environment, "submit", happy_filename)
            rescue Efile::GyrEfilerService::RetryableError
              submission.retry_send_submission # TODO: It's too bad we throw away the log. Should we make "temporary_failure" a state in the state machine and store this output as raw_response?
              next
            rescue StandardError => e
              submission.transition_to!(:failed, error_code: "TRANSMISSION-SERVICE", raw_response: e.inspect)
              raise
            end
            doc = Nokogiri::XML(result)
            if doc.css('SubmissionReceiptList SubmissionReceiptGrp SubmissionId').text.strip == submission.irs_submission_id
              submission.transition_to!(:transmitted, receipt: result)
            else
              submission.transition_to!(:failed, error_code: "TRANSMISSION-RESPONSE", raw_response: result)
            end
          end
        end
      end
    end
  end
end
