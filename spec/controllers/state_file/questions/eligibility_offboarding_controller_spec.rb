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
    let(:params) { { us_state: "az" } }
    let(:intake) { create :state_file_az_intake }

    context "with offboarded_from set in the session" do
      render_views
      let(:offboarded_from_path) do
        StateFile::Questions::AzEligibilityResidenceController.to_path_helper(
          action: :edit, us_state: params[:us_state]
        )
      end
      before do
        sign_in intake
        session[:offboarded_from] = offboarded_from_path
      end


      it "uses the correct prev_path for the Go back button" do
        get :edit, params: params

        expect(Nokogiri::HTML.parse(response.body)).to have_link(href: offboarded_from_path)
        expect(session[:offboarded_from]).to be_nil
      end
    end
  end
end