require "rails_helper"

RSpec.describe Users::SessionsController do
  let(:user) { create :user }
  before do
    sign_in user
    allow(SecureRandom).to receive(:hex).and_return "1234"
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "#destroy" do
    it "signs the user out of the app and sets a flash message" do
      delete :destroy

      expect(subject.current_user).to be_nil
      expect(flash[:notice]).to be_present
    end

    it "sets omniauth state and redirects the user to the ID.me logout endpoint" do
      delete :destroy

      expect(session["omniauth.state"]).to eq "1234"
      expect(response).to redirect_to %r(\Ahttps://api\.idmelabs\.com/oauth/logout)
      redirect_params = Rack::Utils.parse_query(URI.parse(response.location).query)
      expect(redirect_params["state"]).to eq "1234"
      expect(redirect_params["redirect_uri"]).to eq "http://test.host/users/auth/idme/callback?logout=success"
      expect(redirect_params).to include "client_id"
    end

    context "in production" do
      before { allow(Rails).to receive(:env).and_return "production".inquiry }

      it "redirects to the real ID.me api" do
        delete :destroy

        expect(response).to redirect_to %r(\Ahttps://api\.id\.me/oauth/logout)
      end
    end
  end

  describe "#logout_primary_from_idme" do
    it "sets omniauth state and redirects the user to the ID.me logout endpoint" do
      delete :logout_primary_from_idme

      expect(session["omniauth.state"]).to eq "1234"
      expect(response).to redirect_to %r(\Ahttps://api\.idmelabs\.com/oauth/logout)
      redirect_params = Rack::Utils.parse_query(URI.parse(response.location).query)
      expect(redirect_params["state"]).to eq "1234"
      expect(redirect_params["redirect_uri"]).to eq "http://test.host/users/auth/idme/callback?logout=primary"
      expect(redirect_params).to include "client_id"
    end
  end
end