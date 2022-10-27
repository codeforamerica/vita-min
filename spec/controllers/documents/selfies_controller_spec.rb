require "rails_helper"

RSpec.describe Documents::SelfiesController do
  let(:filing_joint) { "no" }
  let(:intake) do
    create(
      :intake,
      filing_joint: filing_joint,
      primary_first_name: "Gary",
      primary_last_name: "Gnome"
    )
  end
  before { sign_in intake.client }

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
  end

  describe "#update" do
    let!(:tax_return) { create :tax_return, :intake_in_progress, client: intake.client }
    let(:params) do
      {
        document_type_upload_form: {
          upload: fixture_file_upload("test-pattern.JPG")
        }
      }
    end

    it "updates the tax return status(es) to intake_needs_doc_help" do
      post :update, params: params

      expect(tax_return.reload.current_state).to eq "intake_needs_doc_help"
    end
  end
end

