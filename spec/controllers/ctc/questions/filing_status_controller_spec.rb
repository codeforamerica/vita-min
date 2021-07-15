require 'rails_helper'

describe Ctc::Questions::FilingStatusController do
  let(:client) { create :client, tax_returns: [(create :tax_return, filing_status: nil)] }
  let!(:intake) { create :ctc_intake, client: client }

  before do
    sign_in intake.client
  end

  describe '#update' do
    context "with no answer" do
      let(:params) do
        {}
      end

      it "re-renders the form with errors" do
        put :update, params: params
        expect(response).to render_template :edit
        expect(assigns(:form).errors).not_to be_blank
        expect(client.tax_returns.first.filing_status).to eq nil
      end
    end

    context "selected single" do
      let!(:params) do
        {
          ctc_filing_status_form:
            { filing_status: "single" }
        }
      end
      it "updates the tax return's filing status" do
        put :update, params: params
        tax_return_status = Intake.last.client.tax_returns.first.filing_status
        expect(tax_return_status).to eq "single"
        expect(response).to redirect_to questions_placeholder_question_path # replace with dependents_questions_path when added
      end
    end

    context "selected married filing jointly" do
      let(:params) do
        {
          ctc_filing_status_form:
            { filing_status: "married_filing_jointly" }
        }
      end
      it "updates the tax return's filing status" do
        put :update, params: params
        tax_return_status = Intake.last.client.tax_returns.first.filing_status
        expect(tax_return_status).to eq "married_filing_jointly"
        expect(response).to redirect_to questions_use_gyr_path #replace with questions_spouse_info when added
      end
    end
  end
end