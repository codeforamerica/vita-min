require "rails_helper"

describe StateFile::CreateNjAnalyticsRecordJob do
  describe "#perform" do
    let!(:submitted_intake) { create :state_file_nj_intake, email_address: 'test+01@example.com', email_address_verified_at: 1.minute.ago }
    let!(:submission) { create :efile_submission, :for_state, data_source: submitted_intake }

    it "updates the NJ analytics record attached to intake" do
      expect(submitted_intake.state_file_nj_analytics).not_to be_present
      described_class.perform_now(submission.id)
      submitted_intake.reload
      expect(submitted_intake.state_file_nj_analytics).to be_present
    end
  end
end