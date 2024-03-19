class BuildSubmissionBundleJob < ApplicationJob
  def perform(submission_id)
    submission = EfileSubmission.includes(:intake, :qualifying_dependents, :verified_address, :tax_return, client: :efile_security_informations).find(submission_id)

    begin
      submission.generate_irs_submission_id!
    rescue StandardError => e
      submission.transition_to!(:failed, error_code: 'IRS-ID-FAIL', raw_response: e.inspect)
    end

    address_creation = submission.generate_verified_address
    unless address_creation.valid?
      submission.transition_to!(:failed, error_source: :usps, error_code: address_creation.error_code, error_message: address_creation.error_message)
      return
    end

    begin
      response = SubmissionBundle.build(submission)
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

  def priority
    PRIORITY_MEDIUM
  end
end
