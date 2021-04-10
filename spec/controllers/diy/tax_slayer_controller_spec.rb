require "rails_helper"

RSpec.describe Diy::TaxSlayerController do
  describe "#show" do
    context "with a diy intake id in the session" do
      before do
        session[:diy_intake_id] = 4
      end

      it "returns 200 OK" do
        get :show

        expect(response).to be_ok
      end
    end

    context "without a valid diy intake id in the session" do
      it "redirects to file yourself page" do
        get :show

        expect(response).to redirect_to diy_file_yourself_path
      end
    end
  end
end
