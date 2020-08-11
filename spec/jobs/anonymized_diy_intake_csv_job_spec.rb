require 'rails_helper'

RSpec.describe AnonymizedDiyIntakeCsvJob, type: :job do
  let(:diy_intakes) { create_list(:diy_intake, 3) }
  let(:fake_service) { double(AnonymizedDiyIntakeCsvService) }
  let(:diy_intake_ids) { diy_intakes.map(&:id) }

  before do
    allow(AnonymizedDiyIntakeCsvService).to receive(:new).with(diy_intake_ids).and_return(fake_service)
    allow(fake_service).to receive(:store_csv)
  end

  describe "#perform" do
    context "when diy intake ids passed in" do
      before do
        described_class.perform_now(diy_intake_ids)
      end

      it "calls the service" do
        expect(AnonymizedDiyIntakeCsvService).to have_received(:new).with(diy_intake_ids)
        expect(fake_service).to have_received(:store_csv)
      end
    end

    context "when no intake ids passed in" do
      let(:diy_intake_ids) { nil }

      before do
        described_class.perform_now
      end

      it "calls the service" do
        expect(AnonymizedDiyIntakeCsvService).to have_received(:new).with(nil)
        expect(fake_service).to have_received(:store_csv)
      end
    end
  end
end

