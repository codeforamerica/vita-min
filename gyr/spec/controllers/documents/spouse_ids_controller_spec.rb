require "rails_helper"

RSpec.describe Documents::SpouseIdsController do
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

  describe "#update" do
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

        it "persists the document as belonging to the 'spouse' person" do
          post :update, params: params
          expect(Document.last).to be_person_spouse
        end
      end
    end
  end

  describe "#delete" do
    let!(:document) { create :document, intake: intake }

    let(:params) do
      { id: document.id }
    end

    it "allows client to delete their own document and records a paper trail" do
      delete :destroy, params: params

      expect(PaperTrail::Version.last.event).to eq "destroy"
      expect(PaperTrail::Version.last.whodunnit).to eq intake.client.id.to_s
      expect(PaperTrail::Version.last.item_id).to eq document.id
    end
  end
end
