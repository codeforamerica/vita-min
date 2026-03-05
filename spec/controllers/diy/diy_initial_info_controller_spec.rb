require "rails_helper"

RSpec.describe Diy::DiyInitialInfoController do
  render_views

  let(:diy_intake) { create(:diy_intake) }

  before do
    allow(subject).to receive(:current_diy_intake).and_return(diy_intake)
  end

  describe "#edit" do
    it "renders successfully" do
      get :edit, session: { diy_intake_id: diy_intake.id }
      expect(response).to be_successful
    end
  end

  describe "#save" do
    context "with valid params" do
      let(:params) do
        {
          diy_initial_info_form: {
            preferred_first_name: "Sylvia",
            state_of_residence: "GU",
            zip_code: 96915
          }
        }
      end

      it "saves the right attributes to the record" do
        post :update, params: params, session: { diy_intake_id: diy_intake.id }

        expect(session[:diy_intake_id]).to eq diy_intake.id

        expect(diy_intake.preferred_first_name).to eq "Sylvia"
        expect(diy_intake.state_of_residence).to eq "GU"
        expect(diy_intake.zip_code).to eq "96915"
      end
    end

    context "with no params entered" do
      let(:params) do
        {
          diy_initial_info_form: {
            preferred_first_name: nil,
            state_of_residence: nil,
            zip_code: nil
          }
        }
      end

      it "works OK and sets those fields to unfilled" do
        post :update, params: params, session: { diy_intake_id: diy_intake.id }

        expect(session[:diy_intake_id]).to eq diy_intake.id

        expect(diy_intake.preferred_first_name).to eq "unfilled"
        expect(diy_intake.state_of_residence).to eq "unfilled"
        expect(diy_intake.zip_code).to eq "unfilled"
      end
    end
  end
end
