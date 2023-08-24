require "rails_helper"

RSpec.describe Documents::IdsController do
  let(:attributes) { {} }
  let(:intake) do
    create(
      :intake,
      primary_first_name: "Gary",
      primary_last_name: "Gnome",
      **attributes
    )
  end

  before { sign_in intake.client }

  describe "#edit" do
    it_behaves_like :a_required_document_controller, person: :primary

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
            upload: fixture_file_upload("test-pattern.html")
          }
        }
      end

      it "renders edit with validation errors" do
        post :update, params: params

        expect(response).to render_template :edit
        expect(response.body).to include "Please upload a valid document type."
      end
    end

    context "when upload is valid" do
      let!(:tax_return) { create :gyr_tax_return, :intake_in_progress, client: intake.client }
      let(:params) do
        {
          document_type_upload_form: {
            upload: fixture_file_upload("test-pattern.JPG")
          }
        }
      end

      context "when participating in the expanded ids experiment" do
        before do
          Experiment.update_all(enabled: true)
          experiment = Experiment.find_by(key: ExperimentService::ID_VERIFICATION_EXPERIMENT)
          experiment.experiment_participants.create(record: intake, treatment: :expanded_id)
        end

        it "persists the document as belonging to the 'primary' person" do
          post :update, params: params
          expect(Document.last).to be_person_primary
        end
      end

      it "updates the tax return status(es) to intake_needs_doc_help" do
        post :update, params: params

        expect(tax_return.reload.current_state).to eq "intake_needs_doc_help"
      end
    end
  end

  context "#delete" do
    let!(:document) { create :document, intake: intake }

    let(:params) do
      { id: document.id }
    end

    it "allows them to delete their own document and redirects back" do
      expect do
        delete :destroy, params: params
      end.to change(Document, :count).by(-1)

      expect(response).to redirect_to ids_documents_path
    end

    it "records a paper trail" do
      delete :destroy, params: params

      expect(PaperTrail::Version.last.event).to eq "destroy"
      expect(PaperTrail::Version.last.whodunnit).to eq intake.client.id.to_s
      expect(PaperTrail::Version.last.item_id).to eq document.id
    end

    context "with a document id that does not exist" do
      let(:params) do
        { id: 123874619823764 }
      end

      it "simply redirects to the documents overview page" do
        expect do
          delete :destroy, params: params
        end.not_to change(Document, :count)

        expect(response).to redirect_to(overview_documents_path)
      end
    end
  end
end
