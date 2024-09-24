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

  describe "#next_path" do
    context 'when not return_to_review' do
      context "when intake is own" do
        let(:intake) { create :state_file_nj_intake, household_rent_own: "own" }

        it "next path is property_tax page" do
          expect(subject.next_path).to eq(StateFile::Questions::NjHomeownerPropertyTaxController.to_path_helper)
        end
      end

      context "when intake is rent" do
        let(:intake) { create :state_file_nj_intake, household_rent_own: "rent" }

        it "next path is rent_paid page" do
          expect(subject.next_path).to eq(StateFile::Questions::NjRenterRentPaidController.to_path_helper)
        end
      end

      context "when intake is neither" do
        let(:intake) { create :state_file_nj_intake, household_rent_own: "neither" }

        it "navigates to next controller in flow" do
          controllers = Navigation::StateFileNjQuestionNavigation::FLOW
          next_controller_to_show = nil
          increment = 1
          while next_controller_to_show.nil?
            next_controller = controllers[controllers.index(described_class) + increment]
            next_controller_to_show = next_controller.show?(intake) ? next_controller : nil
            increment += 1
          end

          expect(subject.next_path).to include(next_controller.controller_name)
        end
      end
    end

    context 'when return_to_review' do
      context "when intake is own" do
        let(:form_params) do
          { state_file_nj_household_rent_own_form: { household_rent_own: "own" } }
        end

        it "navigates to the property_tax page with the param" do
          post :update, params: form_params.merge({return_to_review: "y"})
          expect(response).to redirect_to(controller: "nj_homeowner_property_tax", action: :edit, return_to_review: 'y')
        end
      end

      context "when intake is rent" do
        let(:form_params) do
          { state_file_nj_household_rent_own_form: { household_rent_own: "rent" } }
        end

        it "navigates to the rent_paid page with the param" do
          post :update, params: form_params.merge({return_to_review: "y"})
          expect(response).to redirect_to(controller: "nj_renter_rent_paid", action: :edit, return_to_review: 'y')
        end
      end

      context "when intake is neither" do
        let(:form_params) do
          { state_file_nj_household_rent_own_form: { household_rent_own: "neither" } }
        end

        it "navigates back to review" do
          post :update, params: form_params.merge({return_to_review: "y"})
          expect(response).to redirect_to(controller: "nj_review", action: :edit)
        end
      end
    end
  end

end