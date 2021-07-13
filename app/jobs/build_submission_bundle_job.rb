class BuildSubmissionBundleJob < ApplicationJob
  def perform(submission_id)
    submission = EfileSubmission.includes(:tax_return, :client, intake: [:dependents, :bank_account]).find(submission_id)
    response = SubmissionBundle.build(submission, documents: ["adv_ctc_irs1040"])

    if response.valid?
      submission.transition_to!(:queued)
    else
      submission.transition_to!(:build_failed, error_message: response.errors)
    end
  end
end
