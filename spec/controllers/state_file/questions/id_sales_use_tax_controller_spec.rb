require "rails_helper"

RSpec.describe StateFile::Questions::IdSalesUseTaxController do
  let(:intake) { create :state_file_id_intake }
  before do
    sign_in intake
  end

  describe "#edit" do
    render_views
    it 'succeeds' do
      get :edit
      expect(response).to be_successful
    end
  end

  describe "#update" do
    let(:form_params) do
      {
        state_file_id_sales_use_tax_form: {
          has_unpaid_sales_use_tax: "yes",
          total_purchase_amount: "100"
        }
      }
    end

    it "saves params correctly" do
      post :update, params: form_params
      expect(response).to be_redirect

      intake.reload

      expect(intake).to be_has_unpaid_sales_use_tax_yes
      expect(intake.total_purchase_amount).to eq(100)
    end
  end
end