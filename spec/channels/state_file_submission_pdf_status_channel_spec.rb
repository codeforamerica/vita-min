require 'rails_helper'

RSpec.describe StateFileSubmissionPdfStatusChannel, type: :channel do
  let!(:intake) { create :state_file_az_intake, email_address: 'test+01@example.com', email_address_verified_at: 1.minute.ago }
  let!(:submission) { create :efile_submission, :for_state, data_source: intake }

  before do
    stub_connection current_state_file_intake: intake
  end

  context "subscription behavior" do
    it "subscribes successfully and streams for the correct intake" do
      subscribe
      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_for(intake)
    end
  end

  context "status_update behavior" do
    it "returns processing before the bundle submission PDF job runs" do
      subscribe
      result = perform(:status_update)
      expect(result).to eq({ status: :processing })
    end

    context "with an attached pdf" do
      before do
        allow(intake.submission_pdf).to receive(:attached?).and_return(true)
      end

      it "returns ready after the BuildSubmissionPdfJob runs" do
        subscribe

        result = perform(:status_update)
        expect(result).to eq({ status: :ready })
      end
    end

    context "already has a pdf attached" do
      before do
        allow(intake.submission_pdf).to receive(:attached?).and_return(true)
      end

      it "automatically broadcasts `:ready` upon subscription if the PDF is attached" do
        expect {
          subscribe
        }.to have_broadcasted_to(intake).with("status" => "ready") # Match JSON keys
      end
    end
  end
end
