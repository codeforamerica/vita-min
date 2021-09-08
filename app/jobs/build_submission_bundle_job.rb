class BuildSubmissionBundleJob < ApplicationJob
  def perform(submission_id)
    submission = EfileSubmission.includes(:intake, :dependents, :address, :tax_return, client: :efile_security_informations).find(submission_id)
    address_creation = submission.generate_irs_address
    unless address_creation.valid?
      submission.transition_to!(:failed, error_source: :usps, error_code: address_creation.error_code, error_message: address_creation.error_message)
      return
    end

    begin
      submission.generate_form_1040_pdf
    rescue StandardError => e
      submission.transition_to!(:failed, error_code: 'PDF-1040-FAIL', raw_response: e.inspect)
      raise
    end

    begin
      response = SubmissionBundle.build(submission, documents: ["adv_ctc_irs1040"])
    rescue StandardError => e
      submission.transition_to!(:failed, error_code: 'BUNDLE-FAIL', raw_response: e.inspect)
      raise
    end

    if response.valid?
      submission.transition_to!(:queued)
    else
      submission.transition_to!(:failed, error_code: 'BUNDLE-FAIL', raw_response: response.errors)
    end
  end
end
