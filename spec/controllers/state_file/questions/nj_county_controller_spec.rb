require "rails_helper"

RSpec.describe StateFile::Questions::NjCountyController do
  let(:intake) { create :state_file_nj_intake }
  before do
    sign_in intake
  end

  describe "#update" do
    # requires form_params to be set
    describe "#next_path" do
      let(:form_params) do
        {
          state_file_nj_county_form: {
            county: "Ocean"
          }
        }
      end

      context "with return_to_review param set" do
        it "navigates to the municipality page with the param" do
          post :update, params: form_params.merge({return_to_review: "y"})
          expect(response).to redirect_to(controller: "nj_municipality", action: :edit, return_to_review: 'y')
        end
      end

      context "without return_to_review_param set" do
        it "navigates to the next page in the flow" do
          post :update, params: form_params
          controllers = Navigation::StateFileNjQuestionNavigation::FLOW

          next_controller_to_show = nil
          increment = 1
          while next_controller_to_show.nil?
            next_controller = controllers[controllers.index(described_class) + increment]
            next_controller_to_show = next_controller.show?(intake) ? next_controller : nil
            increment += 1
          end
          expect(response).to redirect_to(controller: next_controller.controller_name, action: next_controller.navigation_actions.first)
        end
      end
    end

  end
end