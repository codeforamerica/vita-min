require "rails_helper"

RSpec.describe Diy::PersonalInfoController do
  render_views

  before do
    allow(Rails.configuration).to receive(:diy_off).and_return false
    Rails.application.reload_routes!
  end

  after do
    allow(Rails.configuration).to receive(:diy_off).and_call_original
    Rails.application.reload_routes!
  end

  describe "#update" do
    before do
      session[:source] = "source_from_session"
      session[:referrer] = "referrer_from_session"
    end

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
        expect(diy_intake.source).to eq "source_from_session"
        expect(diy_intake.locale).to eq "en"
        expect(diy_intake.referrer).to eq "referrer_from_session"
      end
    end

    context "with different locale" do
      let(:params) do
        {
          diy_personal_info_form: {
            state_of_residence: "CO",
            preferred_name: "Shep"
          },
          locale: "es"
        }
      end

      it "saves the locale on the intake" do
        expect {
          post :update, params: params
        }.to change(DiyIntake, :count).by(1)

        diy_intake = DiyIntake.last
        expect(diy_intake.locale).to eq "es"
      end
    end
  end
end
