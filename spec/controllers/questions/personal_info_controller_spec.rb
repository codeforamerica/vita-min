require "rails_helper"

RSpec.describe Questions::PersonalInfoController do
  before do
    allow(subject).to receive(:current_intake).and_return(intake)
  end

  describe "#update" do
    let(:intake) { create :intake }
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
      allow(ClientRouter).to receive(:route)
    end

    it "sets the timezone on the intake" do
      expect { post :update, params: params }
        .to change { intake.timezone }.to("America/New_York")
    end

    context "when a client has not yet consented" do
      before { create :tax_return, client: intake.client, status: "intake_before_consent" }

      it "gets routed" do
        post :update, params: params

        expect(ClientRouter).to have_received(:route).with(intake.client)
      end
    end

    context "when a client has consented" do
      let(:client) { create :client }
      let(:intake) { create :intake, client: client }
      before { create :tax_return, client: intake.client, status: "intake_in_progress" }

      it "does not route" do
        post :update, params: params

        expect(ClientRouter).not_to have_received(:route)
      end
    end
  end
end

