require "rails_helper"

describe Ctc::Questions::PersonalInfoController do
  describe "#edit" do
    it "renders edit template and initializes form" do
      get :edit, params: {}
      expect(response).to render_template :edit
      expect(assigns(:form)).to be_an_instance_of Ctc::PersonalInfoForm
      expect(assigns(:form).intake).to be_an_instance_of Intake::CtcIntake
    end
  end

  describe "#update" do
    let(:params) do
      {
        ctc_personal_info_form: {
          preferred_name: "Gil",
          timezone: "America/Chicago"
        }
      }
    end

    it "saves preferred name, visitor_id, and timezone to intake, and redirects to the next question" do
      get :update, params: params
      intake = Intake.last
      expect(assigns(:form).intake).to be_valid
      expect(intake.preferred_name).to eq "Gil"
      expect(intake.timezone).to eq "America/Chicago"
      expect(intake.visitor_id).to be_present
      expect(response).to redirect_to questions_contact_preference_path
    end

    it "stores the intake to the session" do
      get :update, params: params
      intake = Intake.last
      expect(session[:intake_id]).to eq intake.id
    end
  end
end