require "rails_helper"

RSpec.describe "StateFile::FystSunsetRedirectConcern", type: :controller do
  controller(ApplicationController) do
    include StateFile::FystSunsetRedirectConcern

    def index
      render plain: "ok"
    end
  end

  before do
    allow(controller).to receive(:root_path).and_return("/")

    routes.draw do
      get "anonymous/index" => "anonymous#index"
    end
  end

  context "when the feature flag is enabled" do
    before do
      allow(Flipper).to receive(:enabled?) do |arg| 
        case arg
        in :fyst_sunset_pya_live
          true
        in :use_env_secrets
          false
        end
      end
    end

    it "redirects to root_path" do
      get :index
      expect(response).to redirect_to("/")
    end
  end

  context "when the feature flag is disabled" do
    before do
      allow(Flipper).to receive(:enabled?) do |arg| 
        case arg
        in :fyst_sunset_pya_live
          false
        in :use_env_secrets
          false
        end
      end
    end

    it "does not redirect" do
      get :index
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq("ok")
    end
  end
end
