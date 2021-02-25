require "rails_helper"

RSpec.describe "offseason routes", type: :request do
  context "landing pages during the off-season" do
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

    it "redirects the question welcome page to root" do
      get QuestionNavigation.first.to_path_helper
      expect(response).to redirect_to root_path
    end

    it "other question routes return 200" do
      get QuestionNavigation.controllers.second.to_path_helper
      expect(response).to be_ok
    end

    it "redirects Stimulus routes to root" do
      get stimulus_filed_recently_path
      expect(response).to redirect_to root_path
    end
  end
end