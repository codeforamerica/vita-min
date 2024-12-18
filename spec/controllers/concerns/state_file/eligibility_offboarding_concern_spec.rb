require "rails_helper"

RSpec.describe StateFile::EligibilityOffboardingConcern, type: :controller do
  controller(ApplicationController) do
    include StateFile::EligibilityOffboardingConcern

    def index
      redirect_to next_path
    end
  end

  let(:intake) { create(:state_file_az_intake) }

  describe "#next_path" do
    context "when the intake is ineligible" do
      it "redirects to the eligibility offboarding page" do
        allow(intake).to receive(:has_disqualifying_eligibility_answer?).and_return(true)
        allow(controller).to receive(:current_intake).and_return(intake)
        allow(controller.class).to receive(:to_path_helper) { |params| params }

        get :index, params: {return_to_review: "foo", hacker_param: "bar"}

        params_to_match = ActionController::Parameters.new(return_to_review: "foo").permit!

        expect(response).to redirect_to(StateFile::Questions::EligibilityOffboardingController.to_path_helper)
        expect(controller.class).to have_received(:to_path_helper).with(params_to_match)
        expect(session[:offboarded_from]).to eq(params_to_match) # this would be a url in real life
      end
    end
  end
end
