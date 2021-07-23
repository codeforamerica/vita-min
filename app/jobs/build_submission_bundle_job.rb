class BuildSubmissionBundleJob < ApplicationJob
  def perform(submission_id, skip_address: false)
    submission = EfileSubmission.includes(:intake, :dependents, :client, :address, :tax_return).find(submission_id)
    unless skip_address
      address_creation = submission.generate_irs_address
      unless address_creation.valid?
        submission.transition_to!(:failed, error_message: address_creation.errors)
        return
      end
    end

    response = SubmissionBundle.build(submission, documents: ["adv_ctc_irs1040"])
    if response.valid?
      submission.transition_to!(:queued)
    else
      submission.transition_to!(:failed, error_message: response.errors)
    end
  end
end
