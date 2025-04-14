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
    let(:form_params) do
      {
        state_file_id_health_insurance_premium_form: {
          has_health_insurance_premium: "yes",
          health_insurance_paid_amount: "123"
        }
      }
    end

    it "saves params correctly" do
      post :update, params: form_params
      expect(response).to be_redirect

      intake.reload

      expect(intake).to be_has_health_insurance_premium_yes
      expect(intake.health_insurance_paid_amount).to eq(123)
    end
  end
end