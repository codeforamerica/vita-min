require "rails_helper"

RSpec.describe StateFile::Questions::AzCharitableContributionsController do
  let(:intake) { create :state_file_az_intake }
  before do
    sign_in intake
  end

  describe "#update" do
    let(:form_params) do
      {
        state_file_az_charitable_contributions_form: {
          charitable_contributions: "yes",
          charitable_cash_amount: "100",
          charitable_noncash_amount: "50"
        }
      }
    end

    it "saves params correctly" do
      post :update, params: form_params
      expect(response).to be_redirect

      intake.reload

      expect(intake).to be_charitable_contributions_yes
      expect(intake.charitable_cash_amount).to eq(100)
      expect(intake.charitable_noncash_amount).to eq(50)
    end
  end
end