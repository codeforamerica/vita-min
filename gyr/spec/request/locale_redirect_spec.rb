require "rails_helper"

RSpec.describe "locale redirection", type: :request do

  context "when no language is set as browsing default" do
    it "redirects to the default locale home URL" do
      get "/", headers: {HTTP_ACCEPT_LANGUAGE: nil }
      expect(response).to have_http_status(302)
      expect(response).to redirect_to("/en")
    end
  end

  context "when the default language is set as browsing default" do
    it "redirects to the default locale home URL" do
      get "/", headers: {HTTP_ACCEPT_LANGUAGE: "en" }
      expect(response).to have_http_status(302)
      expect(response).to redirect_to("/en")
    end
  end

  context "when a supported non-default language is set as browsing default" do
    it "redirects to the Spanish locale home URL" do
      get "/", headers: {HTTP_ACCEPT_LANGUAGE: "es" }
      expect(response).to have_http_status(302)
      expect(response).to redirect_to("/es")
    end
  end

  context "when an unsupported language is set as browsing default" do
    it "redirects to the default locale home URL" do
      get "/", headers: {HTTP_ACCEPT_LANGUAGE: "yy" }
      expect(response).to have_http_status(302)
      expect(response).to redirect_to("/en")
    end
  end

end
