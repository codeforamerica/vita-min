module GyrEfiler
  class SendSubmissionJob < ApplicationJob
    def perform(submission)
      Efile::GyrEfilerService.with_lock(ActiveRecord::Base.connection) do |lock_acquired|
        raise Efile::GyrEfilerService::RetryableError, "gyr-efile lock is busy" unless lock_acquired

        Dir.mktmpdir do |tempdir|
          submission.submission_bundle.open do |local_copy|
            happy_filename = File.join(tempdir, submission.submission_bundle.filename.to_s)
            FileUtils.mv(local_copy.path, happy_filename)
            result = Efile::GyrEfilerService.run_efiler_command(Rails.application.config.efile_environment, "submit", happy_filename)
            doc = Nokogiri::XML(result)
            if doc.css('SubmissionReceiptList SubmissionReceiptGrp SubmissionId').text.strip == submission.irs_submission_id
              submission.transition_to!(:transmitted, receipt: result)
            else
              submission.transition_to!(:failed, error_code: "TRANSMISSION-RESPONSE", raw_response: result)
            end
          end
        end
      end
    rescue Efile::GyrEfilerService::RetryableError
      submission.retry_send_submission
      return
    rescue Efile::GyrEfilerService::Error => e
      submission.transition_to!(:failed, error_code: "TRANSMISSION-SERVICE", raw_response: e.inspect)
      raise
    end
  end
end
