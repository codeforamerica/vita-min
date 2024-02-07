require "rails_helper"

RSpec.describe StateFile::Questions::NySchoolDistrictController do
  let(:intake) { create :state_file_ny_intake, residence_county: "Nassau" }
  before do
    sign_in intake
  end

  describe "#update" do
    context "with a valid district id" do
      let(:form_params) {
        {
          state_file_ny_school_district_form: {
            school_district_id: 440,
          }
        }
      }

      it "saves the correct district id, name, and code" do
        post :update, params: { us_state: "ny" }.merge(form_params)

        intake.reload
        expect(intake.school_district_id).to eq 440
        expect(intake.school_district).to eq "Bellmore"
        expect(intake.school_district_number).to eq 46
      end
    end

    context "when the id corresponds to an elementary school district" do
      let(:form_params) {
        {
          state_file_ny_school_district_form: {
            school_district_id: 443,
          }
        }
      }

      it "saves the correct district id, name, and code" do
        post :update, params: { us_state: "ny" }.merge(form_params)

        intake.reload

        expect(intake.school_district_id).to eq 443
        expect(intake.school_district).to eq "Bellmore-Merrick CHS"
        expect(intake.school_district_number).to eq 441
      end
    end

    context "when the screen is part of the review flow" do
      # use the return_to_review_concern shared example if the page
      # should skip to the review page when the return_to_review param is present
      # requires form_params to be set with any other required params
      it_behaves_like :return_to_review_concern do
        let(:form_params) do
          {
            us_state: "ny",
            state_file_ny_school_district_form: {
              school_district_id: 440
            }
          }
        end
      end
    end
  end
end

