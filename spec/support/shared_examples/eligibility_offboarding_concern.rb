require "rails_helper"

shared_examples :eligibility_offboarding_concern do |intake_factory:|
  before do
    sign_in create(intake_factory)
  end

  describe "#edit" do
    context "if session has offboarded_from" do
      before do
        session[:offboarded_from] = "somewhere over the rainbow"
      end

      it "should delete the session offboarded_from data" do
        get :edit
        expect(session[:offboarded_from]).to be_nil
      end
    end
  end

  # requires ineligible_params and eligible_params to be defined
  describe "#next_path" do
    context "with eligible params" do
      it "does not redirect to the eligibility offboarding page" do
        post :update, params: eligible_params

        expect(response).not_to redirect_to(controller: "state_file/questions/eligibility_offboarding", action: :edit)
      end
    end

    context "with ineligible params" do
      it "redirects to the eligibility offboarding page" do
        post :update, params: ineligible_params

        expected_prev_path = described_class.to_path_helper
        expected_redirect_path = url_for(
          controller: "state_file/questions/eligibility_offboarding",
          action: :edit
        )

        expect(response).to redirect_to(expected_redirect_path)
        expect(session[:offboarded_from]).to eq expected_prev_path
      end
    end
  end
end