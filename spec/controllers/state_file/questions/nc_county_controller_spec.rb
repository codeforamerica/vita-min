require 'rails_helper'

RSpec.describe StateFile::Questions::NcCountyController do
  let(:intake) { create :state_file_nc_intake }

  before { sign_in intake }

  describe "#update" do
    let(:form_params) do
      {
        state_file_nc_county_form: {
          residence_county: "001",
          moved_after_hurricane_helene: "yes",
          county_during_hurricane_helene: "011"
        }
      }
    end

    it "saves params correctly" do
      post :update, params: form_params
      expect(response).to be_redirect

      intake.reload

      expect(intake.residence_county).to eq("001")
      expect(intake).to be_moved_after_hurricane_helene_yes
      expect(intake.county_during_hurricane_helene).to eq("011")
    end
  end
end
