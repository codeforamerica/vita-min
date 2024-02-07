require "rails_helper"

shared_examples :eligibility_offboarding_concern do |intake_factory:|
  # requires ineligible_params and eligible_params to be defined
  describe "#next_path" do
    before do
      sign_in create(intake_factory)
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

        state = ineligible_params[:us_state]
        expected_prev_path = described_class.to_path_helper(action: :edit, us_state: state)
        expected_redirect_path = url_for(
          controller: "state_file/questions/eligibility_offboarding",
          action: :edit,
          us_state: state,
        )

        expect(response).to redirect_to(expected_redirect_path)
        expect(session[:offboarded_from]).to eq expected_prev_path
      end
    end
  end
end