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

  describe "#update" do
    let(:valid_params) do
      {
        document_type_upload_form: {
          document: fixture_file_upload("attachments/test-pattern.png", "image/png")
        }
      }
    end

    context "for a client with all identity docs" do
      let!(:tax_return) { create :tax_return, client: intake.client, status: "intake_in_progress" }

      before do
        create :document, client: intake.client, document_type: DocumentTypes::Identity.key
        create :document, client: intake.client, document_type: DocumentTypes::Selfie.key
      end

      it "advances all return statuses to open" do
        post :update, params: valid_params

        expect(tax_return.reload.status).to eq "intake_open"
      end
    end
  end
end

