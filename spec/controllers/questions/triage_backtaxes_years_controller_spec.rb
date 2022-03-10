require 'rails_helper'

RSpec.describe Questions::TriageBacktaxesYearsController do
  before do
    session[:intake_id] = create(:intake).id
  end

  describe "#edit" do
    it "redirects to the triage income levels page" do
      get :edit, params: {}

      expect(response).to redirect_to(Questions::TriageIncomeLevelController.to_path_helper)
    end
  end

  describe "#update" do
    it "redirects to the triage income levels page" do
      post :update, params: {}

      expect(response).to redirect_to(Questions::TriageIncomeLevelController.to_path_helper)
    end
  end
end
