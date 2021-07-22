require "rails_helper"

describe Ctc::Questions::ConfirmLegalController do
  let(:intake) { create :ctc_intake, client: client }
  let(:client) { create :client, tax_returns: [create(:tax_return, year: 2020)] }

  before do
    sign_in intake.client
  end

  describe "#edit" do
    it "renders edit template and initializes form" do
      get :edit, params: {}

      expect(response).to render_template :edit
      expect(assigns(:form)).to be_an_instance_of Ctc::ConfirmLegalForm
      expect(assigns(:form).intake).to be_an_instance_of Intake::CtcIntake
    end
  end

  describe "#update" do
    let(:params) do
      {
        ctc_confirm_legal_form: {
          consented_to_legal: "yes",
        }
      }
    end

    context "when submitting the form" do
      context "when checking 'I agree'" do
        it "create a submission with the status of 'preparing' and send client a message and redirect to portal home" do
          post :update, params: params

          expect(response).to redirect_to ctc_portal_root_path
          expect(client.reload.tax_returns.last.efile_submissions.last.current_state).to eq "preparing"
        end
      end

      context "when not checking 'I agree'" do
        before do
          params[:ctc_confirm_legal_form][:consented_to_legal] = "no"
        end

        it "render edit with errors" do
          post :update, params: params
          expect(response).to render_template :edit
          expect(assigns(:form).errors).not_to be_blank
          expect(intake.consented_to_legal).to eq "unfilled"
        end
      end
    end
  end
end