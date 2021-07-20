require "rails_helper"

describe Ctc::Questions::IpPinController do
  let(:intake) { create :ctc_intake }
  let(:dependent) { create :dependent, intake: intake }

  before do
    sign_in intake.client
  end

  describe "#edit" do
    it "renders edit template and initializes form" do
      get :edit, params: {}

      expect(response).to render_template :edit
      expect(assigns(:form)).to be_an_instance_of Ctc::IpPinForm
      expect(assigns(:form).intake).to be_an_instance_of Intake::CtcIntake
    end
  end

  describe "#update" do
    let(:params) do
      {
        ctc_ip_pin_form: {
          has_primary_ip_pin: "yes",
          has_spouse_ip_pin: "yes",
          dependents_attributes: {
            "0" => {
              id: dependent.id,
              has_ip_pin: "yes",
            }
          }
        }
      }
    end

    context "when submitting the form" do
      it "updates the intake and dependents" do
        post :update, params: params

        expect(intake.reload).to be_has_primary_ip_pin_yes
        expect(intake.reload).to be_has_spouse_ip_pin_yes
        expect(dependent.reload).to be_has_ip_pin_yes
      end
    end
  end
end