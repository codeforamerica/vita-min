require "rails_helper"

RSpec.describe StateFile::Questions::AzSubtractionsController do
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
          state_file_az_subtractions_form: {
            armed_forces_member: "yes",
            armed_forces_wages_amount: "100",
            tribal_member: "yes",
            tribal_wages_amount: "200"
          }
        }
      end
    end
  end
end