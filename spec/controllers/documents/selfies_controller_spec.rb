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

  before do
    ExperimentService.ensure_experiments_exist_in_database
    Experiment.update_all(enabled: true)

    sign_in intake.client
  end

  describe ".show?" do
    context "they aren't in the experiment" do
      it "returns true" do
        expect(subject.class.show?(intake)).to eq true
      end
    end

    context "they are in the experiment" do
      before do
        experiment = Experiment.find_by(key: ExperimentService::ID_VERIFICATION_EXPERIMENT)
        ExperimentParticipant.create!(experiment: experiment, record: intake, treatment: treatment)
      end

      context "they aren't receiving the skip selfie experiment treatment" do
        let(:treatment) { :control }
        it "returns true" do
          expect(subject.class.show?(intake)).to eq true
        end
      end

      context "they are receiving the skip selfie experiment treatment" do
        let(:treatment) { :no_selfie }
        it "returns false" do
          expect(subject.class.show?(intake)).to eq false
        end
      end
    end
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
  end

  describe "#update" do
    let!(:tax_return) { create :gyr_tax_return, :intake_in_progress, client: intake.client }
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

