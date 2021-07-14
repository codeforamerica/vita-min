require 'rails_helper'

describe Ctc::Questions::SpouseSsnController do
  let(:client) { create :client, tax_returns: [(create :tax_return, filing_status: "married_filing_jointly")] }
  let!(:intake) { create :ctc_intake, client: client }

  before do
    sign_in intake.client
  end

  describe "#edit" do
    it "renders the corresponding template" do
      get :edit

      expect(response).to render_template :edit
    end
  end

  # describe '#update' do
  #   let(:filed_previous_years) { "no" }
  #   let(:params) { { triage_backtaxes_form: { filed_previous_years: filed_previous_years } } }
  #   it "persists if spouse has social security number valid for employment" do
  #
  #   end
  # end
end