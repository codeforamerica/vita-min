require "rails_helper"

RSpec.describe StateFile::Questions::NySchoolDistrictController do
  let(:intake) { create :state_file_ny_intake, residence_county: "Nassau" }
  before do
    session[:state_file_intake] = intake.to_global_id
  end

  describe "#edit" do
    it "assigns the correct data structure to @school_districts including combined district names" do
      get :edit, params: { us_state: "ny" }

      school_districts = assigns(:school_districts)
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
  end
end

