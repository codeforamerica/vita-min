require 'rails_helper'

describe Ctc::Questions::FilingStatusController do
  let(:client) { create :client_with_ctc_intake_and_return}
  let(:intake) { client.intake }

  before do
    session[:intake_id] = intake.id
  end

  describe '#update' do
    context "with no answer" do
      let(:params) do
        {
            ctc_filing_status_form: {
                filing_status: ""
            }
        }
      end
      it "re-renders the form with errors" do
        put :update, params: params
        expect(response).to render_template :edit
        expect(assigns(:form).errors).to include(:filing_status)
      end
    end

    context "selected single" do
      let(:params) do
        {
            ctc_filing_status_form: {
                filing_status: "single"
            }
        }
      end
      it "updates the tax return's filing status" do
        post :update, params: params
        tax_return_status = intake.tax_returns.first.filing_status
        expect(tax_return_status).to eq "single"
      end
    end

    context "selected married filing jointly" do
      let(:params) do
        {
            ctc_filing_status_form: {
                filing_status: "married_filing_jointly"
            }
        }
      end
      it "updates the tax return's filing status" do
        put :update, params: params
        tax_return_status = intake.client.tax_returns.first.filing_status
        expect(tax_return_status).to eq "married_filing_jointly"
      end
    end
  end
end