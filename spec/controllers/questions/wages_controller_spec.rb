require "rails_helper"

RSpec.describe Questions::WagesController do
  describe "#edit" do
    context "when there is an intake" do
      let!(:intake) { create :intake }

      before do
        session[:intake_id] = intake.id
      end

      it "renders edit and returns 200" do
        get :edit

        expect(response).to be_ok
      end
    end

    context "when there is no intake" do
      it "redirects to root path" do
        get :edit

        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "#update" do
    context "when there is an intake" do
      let!(:intake) { create :intake }

      before do
        session[:intake_id] = intake.id
      end

      it "updates had_wages on the current intake and returns a redirect" do
        post :update, params: { form: { had_wages: "yes" } }

        intake.reload
        expect(intake.had_wages).to eq "yes"
        expect(response.status).to eq 302
      end
    end
  end
end
