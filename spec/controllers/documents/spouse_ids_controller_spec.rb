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
          ExperimentService.ensure_experiments_exist_in_database
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
end
