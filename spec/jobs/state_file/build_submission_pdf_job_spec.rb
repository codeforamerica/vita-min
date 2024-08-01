require "rails_helper"

describe StateFile::BuildSubmissionPdfJob do
  describe "#perform" do
    let!(:submitted_intake) { create :state_file_az_intake, email_address: 'test+01@example.com', email_address_verified_at: 1.minute.ago }
    let!(:efile_submission) { create :efile_submission, :for_state, data_source: submitted_intake }

    it "generates and attaches the pdf" do
      described_class.perform_now(submission.id)
      submitted_intake.reload!
      expect(submitted_intake.submission_pdf.attached?).to be_truthy
    end
  end
end