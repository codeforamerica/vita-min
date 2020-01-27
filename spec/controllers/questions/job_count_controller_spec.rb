require "rails_helper"

RSpec.describe Questions::JobCountController do
  before do
    allow(subject).to receive(:user_signed_in?).and_return(true)
  end

  describe "#edit" do
    context "when user not signed in" do
      before do
        allow(subject).to receive(:user_signed_in?).and_return(false)
      end

      it "redirects to ID.me login page" do
        get :edit

        expect(response).to redirect_to identity_questions_path
      end
    end
  end
end

