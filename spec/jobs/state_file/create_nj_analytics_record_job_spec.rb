require "rails_helper"

describe StateFile::CreateNjAnalyticsRecordJob do
  describe "#perform" do
    let!(:submitted_intake) { create :state_file_nj_intake, email_address: 'test+01@example.com', email_address_verified_at: 1.minute.ago }
    let!(:submission) { create :efile_submission, :for_state, data_source: submitted_intake }

    it "populates the NJ analytics record attached to intake" do
      expect(submitted_intake.state_file_nj_analytics).not_to be_present
      described_class.perform_now(submission.id)
      submitted_intake.reload
      expect(submitted_intake.state_file_nj_analytics).to be_present
    end

    context "when multiple submissions exist" do
      let!(:submission_2) { create :efile_submission, :for_state, data_source: submitted_intake }
      it "allows multiple NJ analytics records to be attached to one intake" do
        expect(submitted_intake.state_file_nj_analytics).not_to be_present
        described_class.perform_now(submission.id)
        submitted_intake.reload
        described_class.perform_now(submission_2.id)
        expect(submitted_intake.state_file_nj_analytics.size).to eq 2
      end
    end
  end
end