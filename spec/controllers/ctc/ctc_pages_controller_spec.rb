require "rails_helper"

describe Ctc::CtcPagesController do
  describe "#home" do
    context "with the ?ctc_beta=1 query parameter" do
      it "sets the ctc_intake_ok cookie and redirects to intake" do
        get :home, params: {ctc_beta: "1"}

        expect(cookies[:ctc_intake_ok]).to eq('yes')
        expect(response).to redirect_to Ctc::Questions::OverviewController.to_path_helper
      end
    end

    context "without the ?ctc_beta=1 query parameter" do
      it "renders the homepage" do
        get :home
        expect(response).to be_ok
      end
    end
  end
end
