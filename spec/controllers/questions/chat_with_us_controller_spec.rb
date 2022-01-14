require "rails_helper"

RSpec.describe Questions::ChatWithUsController do
  render_views

  let(:vita_partner) { create :organization, name: "Fake Partner" }
  let(:zip_code) { nil }
  let(:intake) { create :intake, vita_partner: vita_partner, zip_code: zip_code }

  before do
    allow(subject).to receive(:current_intake).and_return(intake)
  end

  describe "#edit" do
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

    context "when the client is a returning client" do
      let(:intake) { create :intake, vita_partner: vita_partner, zip_code: zip_code, primary_first_name: "Nancy", client: (create :client, routing_method: "returning_client") }

      it "shows the appropriate returning client text" do
        get :edit

        expect(response).to be_ok
        expect(response.body).to include("Welcome back Nancy")
        expect(response.body).to include("Our team at #{vita_partner.name} is here to help you file again.")
      end
    end

    context "when the client is not a returning client" do
      it "shows the appropriate first time client text" do
        get :edit

        expect(response).to be_ok
        expect(response.body).not_to include("Welcome back Nancy")
        expect(response.body).to include("Our team at #{vita_partner.name} is here to help!")
      end
    end
  end
end
