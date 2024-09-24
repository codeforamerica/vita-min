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

    context "when the screen is part of the review flow" do
      # use the return_to_review_concern shared example if the page
      # should skip to the review page when the return_to_review param is present
      # requires form_params to be set with any other required params
      it_behaves_like :return_to_review_concern do
        let(:form_params) do
          {
            state_file_nj_household_rent_own_form: {
              household_rent_own: :neither
            }
          }
        end
      end
    end
  end

end