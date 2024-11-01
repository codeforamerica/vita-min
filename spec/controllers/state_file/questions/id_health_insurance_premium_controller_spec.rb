require "rails_helper"

RSpec.describe StateFile::Questions::IdHealthInsurancePremiumController do
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
    # use the return_to_review_concern shared example if the page
    # should skip to the review page when the return_to_review param is present
    # requires form_params to be set with any other required params
    it_behaves_like :return_to_review_concern do
      let(:form_params) do
        {
          state_file_id_health_insurance_premium_form: {
            has_health_insurance_premium: "yes",
            health_insurance_paid_amount: "123"
          }
        }
      end
    end
  end
end