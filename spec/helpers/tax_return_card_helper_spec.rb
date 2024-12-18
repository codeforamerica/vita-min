require 'rails_helper'

describe TaxReturnCardHelper do
  describe "#tax_return_status_to_props" do
    (TaxReturnStateMachine.states - ['intake_before_consent']).each do |state|
      context "when the tax return is in #{state}" do
        let(:tax_return) { instance_double(TaxReturn) }

        before do
          allow(tax_return).to receive(:current_state).and_return(state)
          allow(tax_return).to receive(:ready_for_8879_signature?).and_return(false)
          allow(tax_return).to receive(:intake).and_return(Intake.new)
          allow(tax_return).to receive(:time_accepted).and_return(DateTime.now)
        end

        it "returns help text to show in the client portal" do
          expect(helper.tax_return_status_to_props(tax_return)).to match(hash_including(:help_text))
        end
      end
    end

    context "when the intake was previously not routed due to all possible partners being at capacity" do
      let(:tax_return) { instance_double(TaxReturn) }
      let(:client) { build(:client, routing_method: :at_capacity) }

      before do
        allow(tax_return).to receive(:current_state).and_return(:intake_in_progress)
        allow(tax_return).to receive(:intake).and_return(intake)
        allow(intake).to receive(:client).and_return(client)
      end

      context "and they still do not have capacity" do
        let(:intake) { build(:intake,
                             zip_code: PartnerRoutingService::TESTING_AT_CAPACITY_ZIP_CODE,
                             current_step: Questions::ChatWithUsController.to_path_helper) }

        it "redirects to the At Capacity page" do
          expect(helper.tax_return_status_to_props(tax_return)[:link]).to eq Questions::AtCapacityController.to_path_helper
        end
      end

      context "but now they have capacity" do
        let(:intake) { build(:intake,
                             zip_code: "11111",
                             current_step: Questions::AtCapacityController.to_path_helper) }
        let(:partner_routing_service) { instance_double(PartnerRoutingService) }

        before do
          allow(PartnerRoutingService).to receive(:new).and_return(partner_routing_service)
          allow(partner_routing_service).to receive(:determine_partner).and_return(build(:organization))
          allow(partner_routing_service).to receive(:routing_method).and_return(:zip_code)
        end

        it "redirects to the Consent page" do
          expect(helper.tax_return_status_to_props(tax_return)[:link]).to eq Questions::ConsentController.to_path_helper
        end
      end
    end
  end
end
