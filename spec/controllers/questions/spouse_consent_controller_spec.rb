require "rails_helper"

RSpec.describe Questions::SpouseConsentController do
  let(:filing_joint) { "yes" }
  let(:intake) { create :intake, filing_joint: filing_joint }

  before do
    allow(subject).to receive(:current_intake).and_return(intake)
  end

  describe ".show?" do
    context "when they are filing joint" do
      let(:filing_joint) { "yes" }
      it "returns true" do
        expect(Questions::SpouseConsentController.show?(intake)).to eq true
      end
    end

    context "when they are not filing joint" do
      let(:filing_joint) { "no" }
      it "returns false" do
        expect(Questions::SpouseConsentController.show?(intake)).to eq false
      end
    end
  end

  describe "#update" do
    context "with valid params" do
      let (:params) do
        {
          spouse_consent_form: {
            birth_date_year: "1983",
            birth_date_month: "5",
            birth_date_day: "10",
            spouse_full_legal_name: "Greta Gnome",
            spouse_last_four_ssn: "5678"
          }
        }
      end
      let(:ip_address) { "127.0.0.1" }

      before do
        request.remote_ip = ip_address
      end

      it "saves the answer with an ip address" do
        post :update, params: params

        intake.reload
        expect(intake.spouse_consented_to_service_ip).to eq ip_address
      end

      context "with a spouse who uses the authenticate later link" do
        before do
          session[:authenticate_spouse_only] = true
        end

        it "enqueues a job to update the zendesk ticket", active_job: true do
          post :update, params: params

          expect(SendSpouseAuthDocsToZendeskJob).to have_been_enqueued
        end
      end
    end

    context "with invalid params" do
      let (:params) do
        {
          spouse_consent_form: {
            birth_date_year: "1983",
            birth_date_month: nil,
            birth_date_day: "10",
            spouse_full_legal_name: nil,
            spouse_last_four_ssn: nil
          }
        }
      end

      it "renders edit with a validation error message" do
        post :update, params: params

        expect(response).to render_template :edit
        error_messages = assigns(:form).errors.messages
        expect(error_messages[:spouse_last_four_ssn].first).to eq "Please enter the last four digits of your SSN or ITIN."
      end
    end
  end
end