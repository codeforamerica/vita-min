require "rails_helper"

RSpec.describe StateFile::Questions::AzPriorLastNamesController do
  let(:intake) { create :state_file_az_intake }
  before do
    sign_in intake
  end

  it_behaves_like :df_data_required, true, :az

  describe "#update" do
    let(:form_params) do
      {
        state_file_az_prior_last_names_form: {
          has_prior_last_names: "yes",
          prior_last_names: "McTestface",
        }
      }
    end

    it "saves params correctly" do
      post :update, params: form_params
      expect(response).to be_redirect

      intake.reload

      expect(intake).to be_has_prior_last_names_yes
      expect(intake.prior_last_names).to eq("McTestface")
    end
  end
end