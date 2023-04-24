require "rails_helper"

RSpec.describe Users::OmniauthCallbacksController do
  describe "#google_oauth2" do
    let(:user) { create(:admin_user) }
    before do
      allow(User).to receive(:from_omniauth).and_return(user)
      @request.env["devise.mapping"] = Devise.mappings[:user]
    end

    context "when User.from_omniauth returns a user" do
      it "signs the user in" do
        expect do
          post :google_oauth2
        end.to change { controller.current_user }.from(nil).to(user)
      end
    end

    context "when User.from_omniauth returns nil" do
      before do
        allow(User).to receive(:from_omniauth).and_return(nil)
      end

      it "shows the sign-in page with a flash message" do

      end
    end
  end
end
