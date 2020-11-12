require "rails_helper"

RSpec.describe Documents::SsnItinsController do
  let(:filing_joint) { "no" }
  let(:intake) do
    create(
      :intake,
      intake_ticket_id: 1234,
      filing_joint: filing_joint,
      primary_first_name: "Gary",
      primary_last_name: "Gnome"
    )
  end

  before do
    allow(subject).to receive(:current_intake).and_return intake
  end

  describe "#edit" do
    it_behaves_like :a_required_document_controller

    context "when they do not have a spouse" do
      let(:filing_joint) { "no" }

      it "lists only their name" do
        get :edit

        expect(assigns(:names)).to eq ["Gary Gnome"]
      end
    end

    context "when they are filing jointly" do
      context "when we have the spouse name" do
        let(:filing_joint) { "yes" }
        before do
          intake.update(
            spouse_first_name: "Greta",
            spouse_last_name: "Gnome",
          )
        end

        it "includes their name in the list" do
          get :edit

          expect(assigns(:names)).to include "Greta Gnome"
        end
      end

      context "when we don't have the spouse name" do
        let(:filing_joint) { "yes" }

        it "includes placeholder in the list" do
          get :edit

          expect(assigns(:names)).to include "Your spouse"
        end
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

