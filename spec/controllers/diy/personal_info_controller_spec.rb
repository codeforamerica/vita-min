require "rails_helper"

RSpec.describe Diy::PersonalInfoController do
  render_views

  describe "#update" do
    context "with valid params" do
      let(:params) do
        {
          diy_personal_info_form: {
            state_of_residence: "CO",
            preferred_name: "Shep"
          }
        }
      end

      it "creates new diy intake with the state of residence and preferred name params" do
        expect {
          post :update, params: params
        }.to change(DiyIntake, :count).by(1)

        diy_intake = DiyIntake.last
        expect(diy_intake.state_of_residence).to eq "CO"
        expect(diy_intake.preferred_name).to eq "Shep"
      end
    end
  end
end
