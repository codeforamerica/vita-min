require "rails_helper"

RSpec.describe Documents::SsnItinsController do
  let(:filing_joint) { "no" }
  let(:intake) { create :intake, filing_joint: filing_joint }
  let!(:primary_user) { create :user, first_name: "Gary", last_name: "Gnome", intake: intake }

  before do
    allow(subject).to receive(:user_signed_in?).and_return(true)
    allow(subject).to receive(:current_intake).and_return intake
  end

  describe "#edit" do
    context "when they do not have a spouse" do
      let(:filing_joint) { "no" }

      it "lists only their name" do
        get :edit

        expect(assigns(:names)).to eq ["Gary Gnome"]
      end
    end

    context "when they have a spouse" do
      let(:filing_joint) { "yes" }
      let!(:user) { create :user, is_spouse: true, first_name: "Greta", last_name: "Gnome", intake: intake }

      it "includes their name in the list" do
        get :edit

        expect(assigns(:names)).to include "Greta Gnome"
      end
    end

    context "when they have dependents" do
      before { create :dependent, first_name: "Gracie", last_name: "Gnome", intake: intake }

      it "includes their names in the list" do
        get :edit

        expect(assigns(:names)).to include "Gracie Gnome"
      end
    end
  end
end

