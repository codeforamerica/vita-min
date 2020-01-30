require "rails_helper"

RSpec.describe Questions::OverviewController do
  describe "#edit" do
    let(:sign_in_count) { 0 }
    let(:user) { create :user, sign_in_count: sign_in_count, first_name: "Gary" }

    before do
      allow(subject).to receive(:current_user).and_return(user)
    end

    context "with a new user" do
      let(:sign_in_count) { 1 }

      it "returns the correct copy" do
        get :edit

        expect(assigns(:welcome_text)).to eq "Welcome Gary!"
      end
    end

    context "with a returning user" do
      let(:sign_in_count) { 3 }

      it "returns the correct copy" do
        get :edit

        expect(assigns(:welcome_text)).to eq "Welcome back Gary!"
      end
    end
  end
end

