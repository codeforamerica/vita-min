require "rails_helper"

RSpec.describe Diy::StartFilingController, type: :controller do
  let(:diy_intake) { create :diy_intake }

  describe "#start" do
    context "with no DIY intake matching the token" do

      it "redirects to the start of teh DIY flow" do
        get :start, params: {token: "bad_token"}

        expect(response).to redirect_to diy_file_yourself_path
      end
    end

    context "with a DIY intake matching the token" do
      it "renders the page" do
        get :start, params: {token: diy_intake.token}

        expect(response).not_to redirect_to diy_file_yourself_path
      end
    end
  end
end
