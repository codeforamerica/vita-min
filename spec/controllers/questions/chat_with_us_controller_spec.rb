require "rails_helper"

RSpec.describe Questions::ChatWithUsController do
  render_views

  let(:vita_partner) { create :vita_partner, name: "Fake Partner" }
  let(:zip_code) { nil }
  let(:intake) { create :intake, vita_partner: vita_partner, zip_code: zip_code }

  before do
    allow(subject).to receive(:current_intake).and_return(intake)
  end

  describe "#edit" do
    context "with a non-eip intake" do
      context "with an intake with a ZIP code" do
        let(:zip_code) { "02143" }

        it "adds a statement about serving that location" do
          get :edit

          expect(response.body).to include("handles tax returns from")
          expect(response.body).to include("02143 (Somerville, Massachusetts)")
        end
      end

      context "with an intake without a ZIP code" do
        it "does not add a statement and does not error" do
          get :edit

          expect(response).to be_ok
          expect(response.body).not_to include("handles tax returns from")
        end
      end
    end

    context "with EIP-only intake" do
      let(:intake) { create :intake, :eip_only }

      it "shows a short EIP-specific message" do
        get :edit

        # Validate beginning of EIP message
        expect(response.body).to include("We’re here to support you")

        # Validate lack of non-EIP messages
        expect(response.body).not_to include("We know taxes can be hard")
        expect(response.body).not_to include("handles tax returns from")
      end
    end
  end
end
