class BuildSubmissionBundleJob < ApplicationJob
  def perform(submission)
    address_creation = submission.generate_irs_address
    unless address_creation.valid?
      submission.transition_to!(:bundle_failure, error_message: address_creation.errors)
      return
    end

    response = SubmissionBundle.build(submission, documents: ["adv_ctc_irs1040"])
    if response.valid?
      submission.transition_to!(:queued)
    else
      submission.transition_to!(:bundle_failure, error_message: response.errors)
    end
  end
end
