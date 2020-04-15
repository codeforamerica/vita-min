require "rails_helper"

RSpec.describe Documents::IdsController do
  let(:attributes) { {} }
  let(:intake) { create :intake, **attributes }
  let!(:primary_user) { create :user, first_name: "Gary", last_name: "Gnome", intake: intake }

  before do
    allow(subject).to receive(:user_signed_in?).and_return(true)
    allow(subject).to receive(:current_intake).and_return intake
  end

  describe "#edit" do
    context "when they are filing jointly" do
      let(:attributes) { { filing_joint: "yes" } }
      let!(:user) { create :user, first_name: "Greta", last_name: "Gnome", is_spouse: true, intake: intake }

      it "shows copy " do
        get :edit

        expect(assigns(:title)).to eq "Attach photos of ID cards"
        expect(assigns(:help_text)).to eq "The IRS requires us to see a current drivers license, passport, or state ID for you and your spouse."
        expect(assigns(:names)).to eq ["Gary Gnome", "Greta Gnome"]
      end
    end

    context "when they are not filing jointly" do
      let(:attributes) { { filing_joint: "no" } }

      it "returns false" do
        get :edit

        expect(assigns(:title)).to eq "Attach a photo of your ID card"
        expect(assigns(:help_text)).to eq "The IRS requires us to see a current drivers license, passport, or state ID."
        expect(assigns(:names)).to eq ["Gary Gnome"]
      end
    end
  end
end

