require "rails_helper"

RSpec.describe Questions::ScholarshipsController do
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

      it "updates has_scholarship_income on the current intake and returns a redirect" do
        post :update, params: { form: { has_scholarship_income: "yes" } }

        intake.reload
        expect(intake.has_scholarship_income).to eq "yes"
        expect(response.status).to eq 302
      end
    end

    context "when there is no intake" do
      it "redirects to root path" do
        expect {
          post :update, params: { form: { has_scholarship_income: "yes" } }
        }.not_to change(Intake, :count)

        expect(response).to redirect_to(root_path)
      end
    end
  end
end
