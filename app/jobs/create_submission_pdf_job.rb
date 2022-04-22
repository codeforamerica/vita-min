class CreateSubmissionPdfJob < ApplicationJob
  def perform(submission_id)
    submission = EfileSubmission.includes(:intake, :qualifying_dependents, :verified_address, :tax_return).find(submission_id)

    begin
      submission.generate_filing_pdf
    rescue StandardError => e
      DatadogApi.increment('clients.pdf_generation_failed')
      raise
    end
  end
end
