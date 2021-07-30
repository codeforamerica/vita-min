class BuildSubmissionBundleJob < ApplicationJob
  def perform(submission_id)
    submission = EfileSubmission.includes(:intake, :dependents, :client, :address, :tax_return).find(submission_id)
    address_creation = submission.generate_irs_address
    unless address_creation.valid?
      submission.transition_to!(:failed, error_message: address_creation.errors)
      return
    end

    begin
      submission.generate_form_1040_pdf("preparing")
    rescue
      submission.transition_to!(:failed, error_message: "Could not generate PDF Form 1040.")
      return
    end

    response = SubmissionBundle.build(submission, documents: ["adv_ctc_irs1040"])
    if response.valid?
      submission.transition_to!(:queued)
    else
      submission.transition_to!(:failed, error_message: response.errors)
    end
  end
end
