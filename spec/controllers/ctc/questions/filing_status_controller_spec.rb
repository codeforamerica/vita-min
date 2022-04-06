require 'rails_helper'

describe Ctc::Questions::FilingStatusController, requires_default_vita_partners: true do
  describe "first page of ctc intake update behavior" do
    include_context :first_page_of_ctc_intake_update_context, form_name: :ctc_filing_status_form, additional_params: { filing_status: "single" }
    it_behaves_like :first_page_of_ctc_intake_update
  end

  describe '#update' do
    context "with no answer" do
      include_context :first_page_of_ctc_intake_update_context, form_name: :ctc_filing_status_form, additional_params: { filing_status: nil }

      it "re-renders the form with errors" do
        put :update, params: params
        expect(response).to render_template :edit
        expect(assigns(:form).errors).not_to be_blank
      end
    end

    context "selected single" do
      include_context :first_page_of_ctc_intake_update_context, form_name: :ctc_filing_status_form, additional_params: { filing_status: "single" }

      it "updates the tax return's filing status" do
        post :update, params: params
        tax_return_status = Intake.last.client.tax_returns.first.filing_status
        expect(tax_return_status).to eq "single"
      end
    end

    context "selected married filing jointly" do
      include_context :first_page_of_ctc_intake_update_context, form_name: :ctc_filing_status_form, additional_params: { filing_status: "married_filing_jointly" }

      it "updates the tax return's filing status" do
        put :update, params: params
        tax_return_status = Intake.last.client.tax_returns.first.filing_status
        expect(tax_return_status).to eq "married_filing_jointly"
      end
    end
  end
end