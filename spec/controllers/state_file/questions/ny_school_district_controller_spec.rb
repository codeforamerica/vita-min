require "rails_helper"

RSpec.describe StateFile::Questions::NySchoolDistrictController do
  describe "#edit" do
    it "assigns the correct data structure to @school_districts" do
      get :edit, params: { us_state: "ny", residence_county: 'Nassau' }

      school_districts = assigns(:school_districts)
      expect(school_districts).to include(['Bellmore-Merrick CHS North Bellmore', 'Bellmore-Merrick CHS'])
      expect(school_districts).to include(['Carle Place', 'Carle Place'])
      expect(school_districts).to eq school_districts.uniq
    end
  end
end

