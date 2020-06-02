require "rails_helper"

RSpec.describe Diy::StartFilingController, type: :controller do
  let(:diy_intake) { create :diy_intake }

  describe "#start" do
    render_views

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

      it "includes a link to the correct taxslayer start page" do
        get :start, params: { token: diy_intake.token }
        fsa_url = "https://www.taxslayer.com/vita2019fsa?source=TSUSATY2019&sidn=01093601"
        expect(response.body).to include(controller.helpers.sanitize(fsa_url))
      end
    end
  end

  describe "#current_diy_intake" do
    it "finds the Diy Intake by token" do
      get :start, params: {token: diy_intake.token}

      expect(controller.current_diy_intake).to eq(diy_intake)
    end
  end
end
