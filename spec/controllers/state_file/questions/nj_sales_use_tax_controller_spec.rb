require "rails_helper"

RSpec.describe StateFile::Questions::NjSalesUseTaxController do
  let(:intake) { create :state_file_nj_intake }
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
    it_behaves_like :return_to_review_concern do
      let(:form_params) do
        {
          state_file_nj_sales_use_tax_form: {
            untaxed_out_of_state_purchases: "yes",
            sales_use_tax_calculation_method: "automated"
          }
        }
      end
    end
  end
end
