require "rails_helper"

describe Hub::StateFileController do

  describe "#index" do
    context "when they are a state file admin" do
      let(:user) { create(:admin_user, :state_file) }

      before do
        sign_in user
      end

      it "allows them to see the page" do
        get :index
        expect(response).to be_ok
      end
    end

    context "when they are not a state file admin" do
      let(:user) { create(:admin_user) }

      before do
        sign_in user
      end

      it "is forbidden" do
        get :index
        expect(response).to be_forbidden
      end
    end
  end

end