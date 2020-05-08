require "rails_helper"

RSpec.describe Questions::PersonalInfoController do
  let!(:vita_partner) { create :vita_partner, zendesk_group_id: "123" }

  before do
    allow(subject).to receive(:current_intake).and_return(intake)
    allow(intake).to receive(:determine_zendesk_group_id).and_return("123")
  end

  describe "#update" do
    let(:params) do
      {
        personal_info_form: {
          state_of_residence: "co",
          preferred_name: "Shep"
        }
      }
    end

    context "when intake does not have a zendesk ticket id" do
      let(:intake) { create :intake }

      it "re-assigns the vita partner" do
        post :update, params: params

        expect(intake.reload.vita_partner).to eq vita_partner
      end
    end

    context "when intake already has a zendesk ticket id" do
      let!(:old_vita_partner) { create :vita_partner, zendesk_group_id: "345" }
      let(:intake) { create :intake, zendesk_group_id: "345", vita_partner: old_vita_partner }

      it "does not re-assign the vita partner" do
        post :update, params: params

        expect(intake.reload.vita_partner).to eq old_vita_partner
      end
    end
  end
end

