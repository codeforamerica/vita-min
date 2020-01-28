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
        end

        it "does not create a new Intake" do
          expect{
            get :idme
          }.not_to change(Intake, :count)
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
        end

        it "creates a new intake and links the user to it" do
          expect{
            get :idme
          }.to change(Intake, :count).by(1)

          intake = Intake.last
          expect(subject.current_intake).to eq intake
          expect(subject.current_intake).to eq user.reload.intake
        end
      end
    end
  end
end