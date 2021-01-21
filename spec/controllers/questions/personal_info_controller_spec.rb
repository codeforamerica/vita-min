require "rails_helper"

RSpec.describe Questions::PersonalInfoController do
  let(:vita_partner) { create :vita_partner }
  let(:organization_router) { double }
  before do
    allow(subject).to receive(:current_intake).and_return(intake)
  end

  describe "#update" do
    let(:intake) { create :intake, source: "SourceParam" }
    let(:state) { 'CO' }
    let(:params) do
      {
        personal_info_form: {
          timezone: "America/New_York",
          zip_code: "80309",
          preferred_name: "Shep"
        }
      }
    end

    before do
      allow(PartnerRoutingService).to receive(:new).and_return organization_router
      allow(organization_router).to receive(:determine_organization).and_return vita_partner
      allow(organization_router).to receive(:routing_method).and_return :source_param

    end

    it "sets the timezone on the intake" do
      expect { post :update, params: params }
        .to change { intake.timezone }.to("America/New_York")
    end

    context "when a client has not yet consented" do
      before do
        create :tax_return, client: intake.client, status: "intake_before_consent"
      end

      it "gets routed" do
        post :update, params: params

        expect(PartnerRoutingService).to have_received(:new).with(
          {
            source_param: "SourceParam",
            zip_code: "80309"
          }
        )
        expect(organization_router).to have_received(:determine_organization)
      end

      it "updates the intake and the client with the routed organization" do
        expect {
          post :update, params: params
          intake.reload
        }.to change(intake, :vita_partner_id).to(vita_partner.id)
         .and change(intake.client, :vita_partner_id).to(vita_partner.id)
         .and change(intake.client, :routing_method).to eq("source_param")
      end
    end

    context "when a client has consented" do
      let(:client) { create :client }
      let(:intake) { create :intake, client: client }
      before { create :tax_return, client: intake.client, status: "intake_in_progress" }

      it "does not route" do
        post :update, params: params

        expect(organization_router).not_to have_received(:determine_organization)
      end
    end
  end
end

