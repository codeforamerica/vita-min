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
      if e.message.split("\n").any? do |line|
        prefix = "Transaction Result: Fault String: ErrorExceptionDetail - Fault Code: soapenv:Server - Detail: "
        next false unless line.start_with?(prefix)

        parsed_error = Nokogiri::XML(line.slice(prefix.length..))
        error_message_text = parsed_error.xpath('//ns2:ErrorMessageTxt', 'ns2' => 'http://www.irs.gov/a2a/mef/MeFHeader.xsd').text
        error_message_code = parsed_error.xpath('//ns2:ErrorMessageCd', 'ns2' => 'http://www.irs.gov/a2a/mef/MeFHeader.xsd').text
        error_classification_code = parsed_error.xpath('//ns2:ErrorClassificationCd', 'ns2' => 'http://www.irs.gov/a2a/mef/MeFHeader.xsd').text
        next false unless parsed_error && error_message_text && error_message_code && error_classification_code

        next error_classification_code == "REQUEST_ERROR" && error_message_code == "MEF00005" && error_message_text.match(
          /\AMessage with Id: [^ ]+ containing submission ids: [^ ]+ specified in the SubmissionDataList is not globally unique - data violates rule: T0000-014\z/
        )
      end
        submission.transition_to!(:transmitted, raw_response: e.inspect)
      else
        submission.transition_to!(:failed, error_code: "TRANSMISSION-SERVICE", raw_response: e.inspect)
        raise
      end
    end
  end
end
