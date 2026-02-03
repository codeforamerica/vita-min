require "rails_helper"

RSpec.describe Diy::QualificationsController do
  describe "#edit" do
    before do
      allow(controller).to receive(:open_for_diy?).and_return(open_for_diy)
    end

    context "when app if open for DIY" do
      let(:open_for_diy) { true }

      it "is 200 OK 👍" do
        get :edit

        expect(response).to be_ok
      end
    end

    context "when app is closed for DIY" do
      let(:open_for_diy) { false }

      it "redirects to the root path" do
        get :edit

        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "redirects", type: :request do
    it "redirects from /diy to this page's main URL" do
      get "/en/diy"
      expect(response).to redirect_to Diy::QualificationsController.to_path_helper
    end

    it "redirects from /diy/email to this page's main URL" do
      get "/en/diy/email"
      expect(response).to redirect_to Diy::QualificationsController.to_path_helper
    end
  end
end
