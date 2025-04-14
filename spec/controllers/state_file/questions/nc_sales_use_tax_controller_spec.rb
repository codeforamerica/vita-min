require "rails_helper"

RSpec.describe StateFile::Questions::NcSalesUseTaxController do
  let(:intake) { create :state_file_nc_intake }
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
        state_file_nc_sales_use_tax_form: {
          untaxed_out_of_state_purchases: "yes",
          sales_use_tax_calculation_method: "automated"
        }
      }
    end

    it "saves params correctly" do
      post :update, params: form_params
      expect(response).to be_redirect

      intake.reload

      expect(intake).to be_untaxed_out_of_state_purchases_yes
      expect(intake.sales_use_tax_calculation_method).to eq("automated")
    end
  end
end
