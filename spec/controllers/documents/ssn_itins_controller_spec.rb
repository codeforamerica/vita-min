require "rails_helper"

RSpec.describe Documents::SsnItinsController do
  let(:filing_joint) { "no" }
  let(:intake) do
    create(
      :intake,
      filing_joint: filing_joint,
      primary_first_name: "Gary",
      primary_last_name: "Gnome"
    )
  end

  before do
    ExperimentService.ensure_experiments_exist_in_database
    Experiment.update_all(enabled: true)

    sign_in intake.client
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

  describe '#update' do
    context "when upload is valid" do
      let!(:tax_return) { create :gyr_tax_return, :intake_in_progress, client: intake.client }
      let(:params) do
        {
          document_type_upload_form: {
            upload: fixture_file_upload("test-pattern.JPG")
          }
        }
      end

      context 'all three required doc types are present' do
        before do
          create :document, document_type: DocumentTypes::Identity.key, intake: intake, client: intake.client
          create :document, document_type: DocumentTypes::Selfie.key, intake: intake, client: intake.client
        end

        it "updates the tax return status(es) to intake_ready" do
          post :update, params: params

          expect(tax_return.reload.current_state).to eq "intake_ready"
        end
      end

      context 'In the no selfie experiment treatment and other two required doc types are present' do
        before do
          experiment = Experiment.find_by(key: ExperimentService::ID_VERIFICATION_EXPERIMENT)
          ExperimentParticipant.create!(experiment: experiment, record: intake, treatment: :no_selfie)
          create :document, document_type: DocumentTypes::Identity.key, intake: intake, client: intake.client
        end

        it "updates the tax return status(es) to intake_ready" do
          post :update, params: params

          expect(tax_return.reload.current_state).to eq "intake_ready"
        end
      end

      context 'required doc types are missing' do
        it "updates the tax return status(es) to intake_needs_doc_help" do
          post :update, params: params

          expect(tax_return.reload.current_state).to eq "intake_needs_doc_help"
        end

        context "the current state is already needs doc help" do
          it "does not create a new transition"do
            post :update, params: params

            expect(tax_return.reload.current_state).to eq "intake_needs_doc_help"

            expect {
              expect {
                post :update, params: {
                  document_type_upload_form: {
                    upload: fixture_file_upload("test-pattern.JPG")
                  }
                }
              }.to change(Document, :count).by(1)
            }.not_to change(tax_return.tax_return_transitions, :count)

            expect(tax_return.reload.current_state).to eq "intake_needs_doc_help"
          end
        end
      end
    end
  end
end

