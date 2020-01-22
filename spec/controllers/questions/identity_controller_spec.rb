require "rails_helper"

RSpec.describe Questions::IdentityController do
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

      it "does not create a new intake" do
        expect {
          get :edit
        }.not_to change(Intake, :count)

        expect(session[:intake_id]).to eq intake.id
      end
    end

    context "when there is no intake" do
      it "renders edit and returns 200" do
        get :edit

        expect(response).to be_ok
      end

      it "creates a new intake and stores it to the session" do
        expect {
          get :edit
        }.to change(Intake, :count).by(1)

        intake = Intake.last

        expect(session[:intake_id]).to eq intake.id
      end
    end
  end
end
