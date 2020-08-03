require "rails_helper"

RSpec.describe Documents::IdsController do
  let(:attributes) { {} }
  let(:intake) do
    create(
      :intake,
      intake_ticket_id: 1234,
      primary_first_name: "Gary",
      primary_last_name: "Gnome",
      **attributes
    )
  end

  before do
    allow(subject).to receive(:current_intake).and_return intake
  end

  describe "#edit" do
    it_behaves_like :a_required_document_controller

    context "when they are filing jointly" do
      let(:attributes) { { filing_joint: "yes" } }

      context "when we have the spouse name" do
        before do
          intake.update(
            spouse_first_name: "Greta",
            spouse_last_name: "Gnome",
            )
        end

        it "shows the spouse name" do
          get :edit

          expect(assigns(:names)).to eq ["Gary Gnome", "Greta Gnome"]
        end
      end

      context "when we don't have the spouse name" do
        it "shows the placeholder" do
          get :edit

          expect(assigns(:names)).to eq ["Gary Gnome", "Your spouse"]
        end
      end
    end

    context "when they are not filing jointly" do
      let(:attributes) { { filing_joint: "no" } }

      it "shows singular copy" do
        get :edit

        expect(assigns(:names)).to eq ["Gary Gnome"]
      end
    end
  end

  describe "#update" do
    context "with an invalid file upload" do
      render_views

      let(:params) do
        {
          document_type_upload_form: {
            document: fixture_file_upload("attachments/test-pattern.html")
          }
        }
      end

      it "renders edit with validation errors" do
        post :update, params: params

        expect(response).to render_template :edit
        expect(response.body).to include "Please upload a valid document type."
      end
    end
  end
end

