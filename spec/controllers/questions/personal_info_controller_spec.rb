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

    let!(:vita_partner) do
      create :vita_partner, states: [State.find_by(abbreviation: state.upcase)]
    end

    it "sets the timezone on the intake" do
      expect { post :update, params: params }
        .to change { intake.timezone }.to("America/New_York")
    end

    context "when intake does not have an 'In Progress' or later status tax return" do
      before { create :tax_return, client: intake.client, status: "intake_before_consent" }

      it "assigns the vita partner" do
        post :update, params: params

        expect(intake.reload.vita_partner).to eq vita_partner
      end
    end

    context "when intake has partner assigned but no 'In Progress' or later status tax return" do
      let!(:old_vita_partner) { create :vita_partner }
      let(:intake) { create :intake, vita_partner: old_vita_partner }
      before { create :tax_return, client: intake.client, status: "intake_before_consent" }

      it "re-assigns the vita partner" do
        post :update, params: params

        expect(intake.reload.vita_partner).to eq vita_partner
      end
    end

    context "when intake already has a return with 'In Progress' or later status" do
      let!(:old_vita_partner) { create :vita_partner }
      let(:intake) { create :intake, vita_partner: old_vita_partner }
      before { create :tax_return, client: intake.client, status: "intake_in_progress" }

      it "does not re-assign the vita partner" do
        post :update, params: params

        expect(intake.reload.vita_partner).to eq old_vita_partner
      end
    end
  end
end

