require "rails_helper"

shared_examples :return_to_review_concern do
  # requires form_params to be set
  describe "#next_path" do
    context "with return_to_review param set" do
      it "navigates to the state review screen" do
        post :update, params: form_params.merge({return_to_review: "y"})

        expect(response).to redirect_to(controller: "#{state_code}_review", action: edit)
      end
    end

    context "without return_to_review_param set" do
      it "navigates to the next page in the flow" do
        post :update, params: form_params

        controllers = StateFile::StateInformationService.navigation_class(intake.state_code)::FLOW
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
