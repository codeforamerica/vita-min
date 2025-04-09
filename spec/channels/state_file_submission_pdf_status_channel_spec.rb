require 'rails_helper'

RSpec.describe StateFileSubmissionPdfStatusChannel, type: :channel do
  let!(:intake) { create :state_file_az_intake, email_address: 'test+01@example.com', email_address_verified_at: 1.minute.ago }

  before do
    stub_connection current_state_file_intake: intake
  end

  context "subscription behavior" do
    context "when pdf is NOT attached" do
      it "subscribes successfully and streams for the correct intake" do
        subscribe
        expect(subscription).to be_confirmed
        expect(subscription).to have_stream_for(intake)
      end
    end

    context "with an attached pdf" do
      before do
        allow(intake.submission_pdf).to receive(:attached?).and_return(true)
      end

      it "does NOT subscribe and does not stream" do
        subscribe
        expect(subscription).to be_rejected
      end
    end

    context "with (somehow) no current intake" do
      let(:intake) { nil }

      it "does NOT subscribe and does not stream" do
        subscribe
        expect(subscription).to be_rejected
      end
    end
  end

  context "status_update behavior" do
    before do
      allow(intake.submission_pdf).to receive(:attached?).and_return(false)
    end

    it "returns processing before the bundle submission PDF job runs" do
      subscribe
      result = perform(:status_update)
      expect(result).to eq({ status: :processing })
    end

    it "returns processing before the PDF is attached and ready after" do
      subscribe
      result_before = perform(:status_update)
      expect(result_before).to eq({ status: :processing })

      allow(intake.submission_pdf).to receive(:attached?).and_return(true)

      result_after = perform(:status_update)
      expect(result_after).to eq({ status: :ready })
    end
  end
end
