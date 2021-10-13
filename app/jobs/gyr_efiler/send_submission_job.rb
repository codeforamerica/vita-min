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
      # For most errors, transition to failed and raise the error for Sentry.
      #
      # However, if the IRS says our submission ID is not globally unique, we assume the IRS already received it.
      not_unique_text = /Message with Id: [^ ]+ containing submission ids: [^ ]+ specified in the SubmissionDataList is not globally unique - data violates rule: T0000-014/
      if e.message.match?(not_unique_text)
        submission.transition_to!(:transmitted, raw_response: e.inspect)
      else
        submission.transition_to!(:failed, error_code: "TRANSMISSION-SERVICE", raw_response: e.inspect)
        raise
      end
    end
  end
end
