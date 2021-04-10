require "rails_helper"

RSpec.describe Diy::DiyIntakesController do
  describe "#new" do
    it "is 200 OK 👍" do
      get :new

      expect(response).to be_ok
    end
  end

  describe "#create" do
    context "with a valid pair of emails" do
      let(:params) do
        {
          diy_intake: {
            email_address: "example@example.com",
            email_address_confirmation: "example@example.com",
          }
        }
      end

      it "creates a new diy intake and stores the id in the session" do
        expect do
          post :create, params: params
        end.to change(DiyIntake, :count).by(1)

        diy_intake = DiyIntake.last
        expect(session[:diy_intake_id]).to eq diy_intake.id
      end

      it "redirects to the tax slayer link page" do
        post :create, params: params

        expect(response).to redirect_to diy_tax_slayer_path
      end
    end

    context "without a valid email pair" do
      let(:params) do
        {
          diy_intake: {
            email_address: "example@example.com",
            email_address_confirmation: "garbled",
          }
        }
      end

      it "returns 200 and doesn't make a diy intake record" do
        expect do
          post :create, params: params
        end.not_to change(DiyIntake, :count)

        expect(response).to be_ok
      end
    end
  end
end
