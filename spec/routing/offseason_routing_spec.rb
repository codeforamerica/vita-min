require "rails_helper"

RSpec.describe "offseason routes", type: :request do
  context "landing pages during the off-season" do
    it "redirects /full-service to the homepage" do
      get "/full-service"
      expect(response).to redirect_to("/")
    end

    it "redirects /EIP to the homepage" do
      get "/EIP"
      expect(response).to redirect_to("/")
    end

    it "redirects /eip to the homepage" do
      get "/eip"
      expect(response).to redirect_to("/")
    end
  end

  context "when config offseason is true" do
    before do
      allow(Rails.configuration).to receive(:offseason).and_return true
      Rails.application.reload_routes!
    end

    after do
      allow(Rails.configuration).to receive(:offseason).and_call_original
      Rails.application.reload_routes!
    end

    it "redirects question routes to root" do
      get QuestionNavigation.first.to_path_helper
      expect(response).to redirect_to root_path
    end

    it "redirects document routes to root" do
      get "/documents/#{DocumentNavigation.first.to_param}"
      expect(response).to redirect_to "/"
    end

    it "redirects EIP routes to root" do
      get EipOnlyNavigation.first.to_path_helper
      expect(response).to redirect_to root_path
    end

    # we can still access & submit requested documents
    # We cannot access EIP-only flow
    # We cannot access other documents pages
    # sanity check: are there any other controllers that might be handled differently?
     # should we close down stimulus flow?
     # dependents
  end
end