require "rails_helper"

RSpec.describe StateFile::Questions::NyCountyController do
  describe "#edit" do
    it "assigns the correct data structure to @counties" do
      get :edit, params: { us_state: "ny" }

      counties = assigns(:counties)
      expect(counties).to include('Montgomery')
      expect(counties).to include('Nassau')
      expect(counties).to eq counties.uniq
    end
  end
end