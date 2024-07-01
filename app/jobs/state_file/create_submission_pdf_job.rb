module StateFile
  class CreateSubmissionPdfJob < ApplicationJob
    def perform(submission_id)
      submission = EfileSubmission.includes(:intake, :qualifying_dependents, :verified_address, :tax_return).find(submission_id)

      begin
        submission.generate_verified_address
      rescue
        # if the connection to USPS service fails here, that's okay because we can fall back to the unverified address to create the PDF
      end

      begin
        submission.generate_filing_pdf
      rescue StandardError => e
        DatadogApi.increment('clients.pdf_generation_failed')
        raise
      end
    end

    def priority
      PRIORITY_MEDIUM
    end
  end
end
