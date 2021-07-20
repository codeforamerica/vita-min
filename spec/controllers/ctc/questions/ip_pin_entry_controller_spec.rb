require "rails_helper"

describe Ctc::Questions::IpPinEntryController do
  let(:intake) { create :ctc_intake }
  let(:dependent) { create :dependent, intake: intake }

  before do
    sign_in intake.client
  end

  describe "#edit" do
    it "renders edit template and initializes form" do
      get :edit, params: {}

      expect(response).to render_template :edit
      expect(assigns(:form)).to be_an_instance_of Ctc::IpPinEntryForm
      expect(assigns(:form).intake).to be_an_instance_of Intake::CtcIntake
    end
  end

  describe "#update" do
    let(:params) do
      {
        ctc_ip_pin_entry_form: {
          primary_ip_pin: "123456",
          spouse_ip_pin: "123457",
          dependents_attributes: {
            "0" => {
              id: dependent.id,
              ip_pin: "123458",
            }
          }
        }
      }
    end

    context "when submitting the form" do
      it "updates the intake and dependents" do
        post :update, params: params

        intake.reload
        expect(intake.primary_ip_pin).to eq('123456')
        expect(intake.spouse_ip_pin).to eq('123457')
        expect(dependent.reload.ip_pin).to eq('123458')
      end
    end
  end
end
