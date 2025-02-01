require "rails_helper"

RSpec.describe StateFile::Questions::AzMadeAz322ContributionsController do
  let(:intake) { create :state_file_az_intake }
  before do
    sign_in intake
  end

  describe "#edit" do
    render_views

    it "succeeds" do
      get :edit

      expect(response).to be_successful
    end
  end

  describe "#update" do
    it_behaves_like :return_to_review_concern do
      let(:form_params) do
        {
          state_file_az_made_az322_contributions_form: {
            made_az322_contributions: "yes",
          }
        }
      end
    end
  end
end