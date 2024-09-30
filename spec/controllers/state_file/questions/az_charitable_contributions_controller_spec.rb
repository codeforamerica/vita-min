require "rails_helper"

RSpec.describe StateFile::Questions::AzCharitableContributionsController do
  let(:intake) { create :state_file_az_intake }
  before do
    sign_in intake
  end

  describe "#update" do
    # use the return_to_review_concern shared example if the page
    # should skip to the review page when the return_to_review param is present
    # requires form_params to be set with any other required params
    it_behaves_like :return_to_review_concern do
      let(:form_params) do
        {
          state_file_az_charitable_contributions_form: {
            charitable_contributions: "yes",
            charitable_cash_amount: "100",
            charitable_noncash_amount: "50"
          }
        }
      end
    end
  end
end