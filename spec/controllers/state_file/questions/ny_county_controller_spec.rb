require "rails_helper"

RSpec.describe StateFile::Questions::NyCountyController do
  let(:intake) { create :state_file_ny_intake }
  before do
    session[:state_file_intake] = intake.to_global_id
    sign_in intake
  end

  describe "#edit" do
    it "assigns the correct data structure to @counties" do
      get :edit, params: { us_state: "ny" }

      counties = subject.county_options
      expect(counties).to include('Montgomery')
      expect(counties).to include('Nassau')
      expect(counties).to eq counties.uniq
    end
  end

  describe "#update" do
    # use the return_to_review_concern shared example if the page
    # should skip to the review page when the return_to_review param is present
    # requires form_params to be set with any other required params
    it_behaves_like :return_to_review_concern do
      let(:form_params) do
        {
          us_state: "ny",
          state_file_ny_county_form: {
            residence_county: "Albany"
          }
        }
      end
    end
  end
end