require "rails_helper"

RSpec.describe Users::OmniauthCallbacksController do
  describe ".idme" do
    let(:auth) { OmniAuth::AuthHash.new({}) }

    before do
      request.env["omniauth.auth"] = auth
      request.env["devise.mapping"] = Devise.mappings[:user]
      allow(User).to receive(:from_omniauth).with(auth).and_return user
    end

    context "when a user successfully authenticates through ID.me" do
      context "with a returning ID.me user" do
        let(:user) { create :user }

        it "signs the user in and redirects them to the overview page and sets success flash message" do
          get :idme
          expect(subject.current_user).to eq user
          expect(response).to redirect_to(overview_questions_path)
          expect(flash[:notice]).to eq "You're signed in!"
        end
      end

      context "with a new ID.me user" do
        let(:user) { build :user }

        it "saves and signs the user in and sets a new user flash message" do
          expect{
            get :idme
          }.to change(User, :count).by(1)
          expect(subject.current_user).to eq user.reload
          expect(response).to redirect_to(overview_questions_path)
          expect(flash[:notice]).to eq "Thank you for verifying your identity!"
        end
      end
    end
  end
end