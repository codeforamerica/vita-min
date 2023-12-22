require "rails_helper"

RSpec.describe StateFile::Questions::NyCountyController do
  let(:intake) { create :state_file_ny_intake }
  before do
    session[:state_file_intake] = intake.to_global_id
    sign_in intake
  end

  describe "#edit" do
    it "assigns the correct data structure to @counties" do
      get :edit, params: { us_state: "ny" }

      counties = subject.county_options
      expect(counties).to include('Montgomery')
      expect(counties).to include('Nassau')
      expect(counties).to eq counties.uniq
    end
  end

  describe "#update" do

    # requires form_params to be set
    describe "#next_path" do

      let(:form_params) do
        {
          us_state: "ny",
          state_file_ny_county_form: {
            residence_county: "Albany"
          }
        }
      end

      context "with return_to_review param set" do
        it "navigates to the state review screen" do
          post :update, params: form_params.merge({return_to_review: "y"})
          expect(response).to redirect_to(controller: "ny_school_district", action: :edit, us_state: "ny", return_to_review: 'y')
        end
      end

      context "without return_to_review_param set" do
        it "navigates to the next page in the flow" do
          post :update, params: form_params
          controllers = []
          controllers = Navigation::StateFileNyQuestionNavigation::FLOW.to_a

          next_controller_to_show = nil
          increment = 1
          while next_controller_to_show.nil?
            next_controller = controllers[controllers.index(described_class) + increment]
            next_controller_to_show = next_controller.show?(intake) ? next_controller : nil
            increment += 1
          end
          expect(response).to redirect_to(controller: next_controller.controller_name, action: next_controller.navigation_actions.first, us_state: form_params[:us_state])
        end
      end
    end

  end
end