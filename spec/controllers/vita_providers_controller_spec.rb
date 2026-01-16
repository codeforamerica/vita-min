require "rails_helper"

RSpec.describe VitaProvidersController do
  before do
    allow(subject).to receive(:send_mixpanel_event)
  end

  describe "#include_analytics?" do
    it "returns true" do
      expect(subject.include_analytics?).to eq true
    end
  end

  describe "#index" do
    it "redirects to IRS search tool URL" do
      get :index
      expect(response).to redirect_to(VitaProvidersController::IRS_VITA_SITE_LOCATOR_URL)
    end
  end
end
