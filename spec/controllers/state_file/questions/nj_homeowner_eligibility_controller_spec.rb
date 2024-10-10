require "rails_helper"

RSpec.describe StateFile::Questions::NjHomeownerEligibilityController do
  let(:intake) { create :state_file_nj_intake }
  before do
    sign_in intake
  end

  describe "#edit" do
    render_views
    it 'succeeds' do
      get :edit
      expect(response).to be_successful
    end

    context "when a user is a homeowner" do
      let(:form_params) {
        {
          state_file_nj_homeowner_eligibility_form: {
            homeowner_home_subject_to_property_taxes: :yes,
            homeowner_more_than_one_main_home_in_nj: :no,
            homeowner_shared_ownership_not_spouse: :yes,
          }
        }
      }

      it "saves the checkbox selections" do
        post :update, params: form_params

        intake.reload
        expect(intake.homeowner_home_subject_to_property_taxes).to eq "yes"
        expect(intake.homeowner_more_than_one_main_home_in_nj).to eq "no"
        expect(intake.homeowner_shared_ownership_not_spouse).to eq "yes"
      end
    end
  end

  describe "#show?" do
    context "when indicated that they own" do
      let(:intake) { create :state_file_nj_intake, household_rent_own: "own" }
      it "shows" do
        expect(described_class.show?(intake)).to eq true
      end
    end

    context "when indicated that they rent" do
      let(:intake) { create :state_file_nj_intake, household_rent_own: "rent" }
      it "does not show" do
        expect(described_class.show?(intake)).to eq false
      end
    end

    context "when indicated neither rent nor own" do
      let(:intake) { create :state_file_nj_intake, household_rent_own: "neither" }
      it "does not show" do
        expect(described_class.show?(intake)).to eq false
      end
    end

    context "when indicated both rent and own" do
      let(:intake) { create :state_file_nj_intake, household_rent_own: "both" }
      it "does not show" do
        expect(described_class.show?(intake)).to eq false
      end
    end
  end

  describe "#next_path" do
    context "when ineligible hard no" do
      let(:intake) { create :state_file_nj_intake, homeowner_home_subject_to_property_taxes: "no" }
      it "next path is ineligible page" do
        expect(subject.next_path).to eq(StateFile::Questions::NjIneligiblePropertyTaxController.to_path_helper)
      end
    end

    context "when unsupported soft no" do
      let(:intake) { create :state_file_nj_intake, homeowner_more_than_one_main_home_in_nj: "yes" }
      it "next path is unsupported page" do
        expect(subject.next_path).to eq(StateFile::Questions::NjUnsupportedPropertyTaxController.to_path_helper)
      end
    end

    context "when advance state" do
      let(:intake) { create :state_file_nj_intake, homeowner_home_subject_to_property_taxes: "yes" }
      it "next path is property tax page" do
        expect(subject.next_path).to eq(StateFile::Questions::NjHomeownerPropertyTaxController.to_path_helper)
      end
    end
  end
end

