require 'rails_helper'

RSpec.describe StateFile::Questions::EligibilityOffboardingController do
  describe ".show?" do
    context "when the intake has a disqualifying answer" do
      it "returns true" do
        intake = double("intake", has_disqualifying_eligibility_answer?: true)
        expect(described_class.show?(intake)).to eq true
      end
    end

    context "when the intake does not have a disqualifying answer" do
      it "returns false" do
        intake = double("intake", has_disqualifying_eligibility_answer?: false)
        expect(described_class.show?(intake)).to eq false
      end
    end
  end

  describe "#edit" do
    render_views
    before do
      sign_in intake
    end

    context "with offboarded_from set in the session" do
      let(:intake) { create :state_file_id_intake }
      let(:offboarded_from_path) do
        StateFile::Questions::IdEligibilityResidenceController.to_path_helper
      end
      before do
        session[:offboarded_from] = offboarded_from_path
      end

      it "uses the correct prev_path for the Go back button" do
        get :edit

        expect(Nokogiri::HTML.parse(response.body)).to have_link(href: offboarded_from_path)
        expect(session[:offboarded_from]).to be_nil
      end
    end

    context "AZ" do
      let(:intake) { create :state_file_az_intake }
  
      it "does not show NJ-specific content" do
        get :edit
        expect(response.body).not_to include("Get connected now")
      end
    end
  
    context "ID" do
      let(:intake) { create :state_file_id_intake }
  
      it "does not show NJ-specific content" do
        get :edit
        expect(response.body).not_to include("Get connected now")
      end
    end
  
    context "MD" do
      let(:intake) { create :state_file_md_intake }
  
      it "does not show NJ-specific content" do
        get :edit
        expect(response.body).not_to include("Get connected now")
      end
    end
  
    context "NJ" do
      let(:intake) { create :state_file_nj_intake }
  
      it "shows NJ-specific content" do
        get :edit
        expect(response.body).to include("Get connected now")
      end
    end
  end
end
