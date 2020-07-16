require "rails_helper"

RSpec.describe Questions::PersonalInfoController do
  let!(:vita_partner) { create :vita_partner, zendesk_group_id: "123" }

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

    let(:vita_partner) do
      State.find_by(abbreviation: state.upcase).vita_partners.first
    end

    it "sets the timezone on the intake" do
      expect { post :update, params: params }
        .to change { intake.timezone }.to("America/New_York")
    end

    context "when intake does not have a zendesk ticket id" do
      it "re-assigns the vita partner" do
        post :update, params: params

        expect(intake.reload.vita_partner).to eq vita_partner
      end
    end

    context "when intake has partner assigned but no zendesk ticket id" do
      let!(:old_vita_partner) { create :vita_partner, zendesk_group_id: "345" }
      let(:intake) { create :intake, vita_partner_group_id: "345", vita_partner: old_vita_partner }

      it "re-assigns the vita partner" do
        post :update, params: params

        expect(intake.reload.vita_partner).to eq vita_partner
      end
    end

    context "when intake already has a zendesk ticket id" do
      let!(:old_vita_partner) { create :vita_partner, zendesk_group_id: "345" }
      let(:intake) { create :intake, intake_ticket_id: 'some-ticket', vita_partner_group_id: "345", vita_partner: old_vita_partner }

      it "does not re-assign the vita partner" do
        post :update, params: params

        expect(intake.reload.vita_partner).to eq old_vita_partner
      end
    end
  end
end

