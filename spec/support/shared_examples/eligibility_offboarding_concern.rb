require "rails_helper"

shared_examples :eligibility_offboarding_concern do |intake_factory:|
  # requires ineligible_params and eligible_params to be defined
  describe "#next_path" do
    before do
      session[:state_file_intake] = create(intake_factory).to_global_id
    end

    context "with eligible params" do
      it "does not redirect to the eligibility offboarding page" do
        post :update, params: eligible_params

        expect(response).not_to redirect_to(controller: "state_file/questions/eligibility_offboarding", action: :edit, us_state: ineligible_params[:us_state])
      end
    end

    context "with ineligible params" do
      it "redirects to the eligibility offboarding page" do
        post :update, params: ineligible_params

        expect(response).to redirect_to(controller: "state_file/questions/eligibility_offboarding", action: :edit, us_state: ineligible_params[:us_state])
      end
    end
  end
end