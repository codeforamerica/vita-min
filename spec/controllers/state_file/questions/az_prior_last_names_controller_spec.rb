require "rails_helper"

RSpec.describe StateFile::Questions::AzPriorLastNamesController do
  let(:intake) { create :state_file_az_intake }
  before do
    session[:state_file_intake] = intake.to_global_id
  end

  describe "#update" do
    # use the return_to_review_concern shared example if the page
    # should skip to the review page when the return_to_review param is present
    # requires form_params to be set with any other required params
    it_behaves_like :return_to_review_concern do
      let(:form_params) do
        {
          us_state: "az",
          state_file_az_prior_last_names_form: {
            has_prior_last_names: "yes",
            prior_last_names: "McTestface"
          }
        }
      end
    end
  end
end