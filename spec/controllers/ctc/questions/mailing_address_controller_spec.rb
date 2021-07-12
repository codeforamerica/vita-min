require "rails_helper"

describe Ctc::Questions::MailingAddressController do
  let(:intake) { create :ctc_intake }

  before do
    sign_in intake.client
  end

  describe "#edit" do
    it "renders edit template and initializes form" do
      get :edit, params: {}
      expect(response).to render_template :edit
      expect(assigns(:form)).to be_an_instance_of Ctc::MailingAddressForm
      expect(assigns(:form).intake).to be_an_instance_of Intake::CtcIntake
    end
  end

  describe "#update" do
    let(:params) do
      {
        ctc_mailing_address_form: {
          street_address: "123 Main St",
          street_address2: "STE 5",
          state: "TX",
          city: "Newton",
          zip_code: "77494"
        }
      }
    end

    context "when the form is not valid" do
      before do
        allow_any_instance_of(Ctc::MailingAddressForm).to receive(:valid?).and_return false
      end
      it "renders the edit page" do
        get :update, params: params
        expect(response).to render_template :edit
      end
    end

    it "updates the intake and redirects to the next question" do
      expect {
        get :update, params: params
      }.to change { intake.reload.updated_at }

      expect(response).to redirect_to questions_confirm_mailing_address_path
    end
  end
end