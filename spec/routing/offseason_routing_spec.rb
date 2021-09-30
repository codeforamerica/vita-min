require "rails_helper"

RSpec.describe "offseason routes", type: :request do

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

    context "when a client is logged in" do
      let(:client) { create :client }
      before do
        login_as(client, scope: :client)
      end

      it "other question routes return 200" do
        get QuestionNavigation.controllers.second.to_path_helper
        expect(response).to be_ok
      end
    end

    context "when a client is not logged in in" do
      it "other question routes redirect to root path" do
        get QuestionNavigation.controllers.second.to_path_helper
        expect(response).to redirect_to root_path
      end
    end
  end
end