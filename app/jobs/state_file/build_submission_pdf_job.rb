module StateFile
  class BuildSubmissionPdfJob < ApplicationJob
    after_perform do |job|
      intake = EfileSubmission.find(job.arguments.first).data_source
      StateFileSubmissionPdfStatusChannel.broadcast_status(intake, :ready)
    end

    def perform(submission_id)
      submission = EfileSubmission.find(submission_id)
      submission.data_source.submission_pdf.attach(
        io: submission.generate_filing_pdf,
        filename: "#{submission.irs_submission_id}.pdf",
        content_type: 'application/pdf'
      )
    end

    def priority
      PRIORITY_MEDIUM
    end
  end
end
