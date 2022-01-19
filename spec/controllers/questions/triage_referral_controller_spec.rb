require 'rails_helper'

RSpec.describe Questions::TriageReferralController do
  describe "#edit" do
    let(:triage) { create(:triage, income_level: income_level) }

    before do
      session[:triage_id] = triage.id
    end

    context "when the current_triage has income within the DIY limit" do
      let(:income_level) { "hh_25101_to_66000" }

        it "shows the page" do
          get :edit

          expect(response).to be_ok
        end
      end
    context "when the current_triage has income above the DIY limit" do
      let(:income_level) { "hh_over_73000" }

      it "redirects to the welcome page" do
        get :edit

        expect(response).to redirect_to(Questions::WelcomeController.to_path_helper)
      end
    end
  end
end
