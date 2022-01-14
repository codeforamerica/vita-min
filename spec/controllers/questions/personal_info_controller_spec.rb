require "rails_helper"

RSpec.describe Questions::PersonalInfoController do
  let(:vita_partner) { create :organization }
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
          preferred_name: "Shep",
          phone_number: "+14156778899",
          phone_number_confirmation: "+14156778899"
        }
      }
    end

    before do
      allow(PartnerRoutingService).to receive(:new).and_return organization_router
      allow(organization_router).to receive(:determine_partner).and_return vita_partner
      allow(organization_router).to receive(:routing_method).and_return :source_param
    end

    it "sets the timezone on the intake" do
      expect { post :update, params: params }
        .to change { intake.timezone }.to("America/New_York")
    end

    it "sets preferred name, zip code and phone number" do
      expect { post :update, params: params }
        .to change { intake.preferred_name }.to("Shep").and change { intake.zip_code }.to("80309").and change { intake.phone_number }.to("+14156778899")
    end
  end
end

