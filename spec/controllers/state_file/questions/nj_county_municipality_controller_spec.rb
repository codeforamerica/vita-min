require "rails_helper"

RSpec.describe StateFile::Questions::NjCountyMunicipalityController do
  let(:intake) { create :state_file_nj_intake }
  before do
    sign_in intake
  end

  describe "#update" do
    context "with a valid municipality code" do
      let(:form_params) {
        {
          state_file_nj_county_municipality_form: {
            municipality_code: "0501",
            county: "Cape May"
          }
        }
      }

      it "saves the correct name and code" do
        post :update, params: form_params

        intake.reload
        expect(intake.municipality_code).to eq "0501"
        expect(intake.municipality_name).to eq "Avalon Borough"
        expect(intake.county).to eq "Cape May"
      end
    end

    context "when the screen is part of the review flow" do
      # use the return_to_review_concern shared example if the page
      # should skip to the review page when the return_to_review param is present
      # requires form_params to be set with any other required params
      it_behaves_like :return_to_review_concern do
        let(:form_params) do
          {
            state_file_nj_county_municipality_form: {
              municipality_code: "0501",
              county: "Cape May"
            }
          }
        end
      end
    end

  end
end