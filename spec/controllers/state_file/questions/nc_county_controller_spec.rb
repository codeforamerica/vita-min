require 'rails_helper'

RSpec.describe StateFile::Questions::NcCountyController do
  let(:intake) { create :state_file_nc_intake }

  before { sign_in intake }

  describe "#update" do
    it_behaves_like :return_to_review_concern do
      let(:form_params) do
        {
          state_file_nc_county_form: {
            residence_county: "001",
            moved_after_hurricane_helene: "yes",
            county_during_hurricane_helene: "011"
          }
        }
      end
    end
  end
end
