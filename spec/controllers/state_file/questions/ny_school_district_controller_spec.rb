require "rails_helper"

RSpec.describe StateFile::Questions::NySchoolDistrictController do
  let(:intake) { create :state_file_ny_intake, residence_county: "Nassau" }
  before do
    session[:state_file_intake] = intake.to_global_id
    sign_in intake
  end

  describe "#edit" do
    it "assigns the correct data structure to @school_districts including combined district names" do
      get :edit, params: { us_state: "ny" }

      school_districts = subject.school_district_options
      expect(school_districts).to include(['Bellmore-Merrick CHS North Bellmore', 'Bellmore-Merrick CHS North Bellmore'])
      expect(school_districts).to include(['Carle Place', 'Carle Place'])
      expect(school_districts).to eq school_districts.uniq
    end
  end

  describe "#update" do
    context "when the code maps to the district name" do
      let(:form_params) {
        {
          state_file_ny_school_district_form: {
            school_district: "Bellmore",
          }
        }
      }

      it "sets the correct district number in params" do
        post :update, params: { us_state: "ny" }.merge(form_params)

        intake.reload
        expect(intake.school_district).to eq "Bellmore"
        expect(intake.school_district_number).to eq 46
      end
    end

    context "when the code comes from an elementary school district" do
      let(:form_params) {
        {
          state_file_ny_school_district_form: {
            school_district: "Bellmore-Merrick CHS North Bellmore",
          }
        }
      }

      it "sets the district name back to the original and uses the correct district number" do
        post :update, params: { us_state: "ny" }.merge(form_params)

        intake.reload
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
              school_district: "Bellmore"
            }
          }
        end
      end
    end
  end
end

