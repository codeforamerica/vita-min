require 'rails_helper'

RSpec.describe AnonymizedIntakeCsvJob, type: :job do
  let(:intakes) { create_list(:intake, 3) }
  let(:other_intake) { create :intake }
  let(:fake_intake_csv_service) { double(AnonymizedIntakeCsvService) }
  let(:intake_ids) { intakes.map(&:id) }

  before do
    allow(AnonymizedIntakeCsvService).to receive(:new).with(intake_ids).and_return(fake_intake_csv_service)
    allow(fake_intake_csv_service).to receive(:store_csv)
  end

  describe "#perform" do
    context "when intake ids passed in" do
      before do
        described_class.perform_now(intake_ids)
      end

      it "calls the service" do
        expect(AnonymizedIntakeCsvService).to have_received(:new).with(intake_ids)
        expect(fake_intake_csv_service).to have_received(:store_csv)
      end
    end

    context "when no intake ids passed in" do
      let(:intake_ids) { nil }
      before do
        described_class.perform_now
      end

      it "calls the service" do
        expect(AnonymizedIntakeCsvService).to have_received(:new).with(nil)
        expect(fake_intake_csv_service).to have_received(:store_csv)
      end
    end
  end
end

