require "rails_helper"

RSpec.describe StateFile::Questions::NjHouseholdRentOwnController do
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

    context "when a user is a renter" do
      let(:form_params) {
        {
          state_file_nj_household_rent_own_form: {
            household_rent_own: :rent,
          }
        }
      }

      it "saves the correct value for renter" do
        post :update, params: form_params

        intake.reload
        expect(intake.household_rent_own).to eq "rent"
      end
    end
  end

  describe "#update" do
    context "when a user changes from neither to homeowner" do
      let(:intake) { create :state_file_nj_intake, household_rent_own: :neither }
      let(:form_params) {
        {
          state_file_nj_household_rent_own_form: {
            household_rent_own: :own,
          }
        }
      }

      it "saves the correct name and code" do
        expect(intake.household_rent_own).to eq "neither"
        post :update, params: form_params
        intake.reload
        expect(intake.household_rent_own).to eq "own"
      end
    end
  end

  describe "#next_path" do
    context 'when not return_to_review' do
      context "when intake is own" do
        let(:intake) { create :state_file_nj_intake, household_rent_own: "own" }

        it "next path is homeowner eligibility page" do
          expect(subject.next_path).to eq(StateFile::Questions::NjHomeownerEligibilityController.to_path_helper)
        end
      end

      context "when intake is rent" do
        let(:intake) { create :state_file_nj_intake, household_rent_own: "rent" }

        it "next path is tenant eligibility page" do
          expect(subject.next_path).to eq(StateFile::Questions::NjTenantEligibilityController.to_path_helper)
        end
      end

      context "when intake is neither" do
        let(:intake) { create :state_file_nj_intake, household_rent_own: "neither" }

        it "next path is ineligible page" do
          expect(subject.next_path).to eq(StateFile::Questions::NjIneligiblePropertyTaxController.to_path_helper)
        end
      end

      context "when intake is both" do
        let(:intake) { create :state_file_nj_intake, household_rent_own: "both" }

        it "next path is ineligible page" do
          expect(subject.next_path).to eq(StateFile::Questions::NjIneligiblePropertyTaxController.to_path_helper)
        end
      end

      context "when not eligible for property tax deduction due to income" do
        let(:intake) {create :state_file_nj_intake, :df_data_minimal, household_rent_own: "own" }
        it "next path is whichever is next overall" do
          allow_any_instance_of(described_class.superclass).to receive(:next_path).and_return("/mocked/super/path")
          expect(subject.next_path).to eq("/mocked/super/path")
        end
      end

      context "when not eligible for property tax deduction due to income but could be eligible for credit" do
        let(:intake) {create :state_file_nj_intake, :df_data_minimal, :primary_disabled, household_rent_own: "own" }
        it "next path is eligibility page for own/rent status" do
          expect(subject.next_path).to eq(StateFile::Questions::NjHomeownerEligibilityController.to_path_helper)
        end
      end
    end

    context 'when return_to_review' do
      context "when intake is own" do
        let(:form_params) do
          { state_file_nj_household_rent_own_form: { household_rent_own: "own" } }
        end

        it "navigates to the tenant eligibility page with the param" do
          post :update, params: form_params.merge({return_to_review: "y"})
          expect(response).to redirect_to(controller: "nj_homeowner_eligibility", action: :edit, return_to_review: 'y')
        end
      end

      context "when intake is rent" do
        let(:form_params) do
          { state_file_nj_household_rent_own_form: { household_rent_own: "rent" } }
        end

        it "navigates to the tenant eligibility page with the param" do
          post :update, params: form_params.merge({return_to_review: "y"})
          expect(response).to redirect_to(controller: "nj_tenant_eligibility", action: :edit, return_to_review: 'y')
        end
      end

      context "when intake is neither" do
        let(:form_params) do
          { state_file_nj_household_rent_own_form: { household_rent_own: "neither" } }
        end

        it "navigates to the ineligible page with the param" do
          post :update, params: form_params.merge({return_to_review: "y"})
          expect(response).to redirect_to(controller: "nj_ineligible_property_tax", action: :edit, return_to_review: 'y')
        end
      end

      context "when intake is both" do
        let(:form_params) do
          { state_file_nj_household_rent_own_form: { household_rent_own: "both" } }
        end

        it "navigates to the ineligible page with the param" do
          post :update, params: form_params.merge({return_to_review: "y"})
          expect(response).to redirect_to(controller: "nj_ineligible_property_tax", action: :edit, return_to_review: 'y')
        end
      end
    end
  end
end

