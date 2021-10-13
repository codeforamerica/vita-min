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

      it "questions still redirect to root path" do
        get QuestionNavigation.controllers.second.to_path_helper
        expect(response).to redirect_to root_path
      end
    end

    context "when a client is not logged in in" do
      it "other question routes redirect to root path" do
        get QuestionNavigation.controllers.second.to_path_helper
        expect(response).to redirect_to root_path
      end
    end

    context "diy routing" do
      context "/diy" do
        it "redirects home" do
          get "/diy"
          expect(response).to redirect_to root_path
        end
      end

      context "/diy/file-yourself" do
        it "redirects home" do
          get "/diy/file-yourself"
          expect(response).to redirect_to root_path
        end
      end

      context "/diy/something" do
        it "redirects home" do
          get "/diy/something"
          expect(response).to redirect_to root_path
        end
      end

      context "post to /diy routes" do
        it "redirects home" do
          post "/diy/email"
          expect(response).to redirect_to root_path
        end
      end
    end

    context "logging in" do
      context "login" do
        it "redirects home" do
          get "/portal/login"
          expect(response).to redirect_to root_path
        end
      end

      context "/login/check-verification" do
        it "redirects home" do
          put "/portal/login/check-verification"
          expect(response).to redirect_to root_path
        end
      end

      context "/login/locked" do
        it "redirects home" do
          get "/portal/login/locked"
          expect(response).to redirect_to root_path
        end
      end
    end
  end
end