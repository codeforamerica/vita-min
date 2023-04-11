require "rails_helper"

RSpec.describe Questions::ChatWithUsController do
  render_views

  let(:vita_partner) { create :organization, name: "Fake Partner" }
  let(:zip_code) { nil }
  let(:intake) { create :intake, vita_partner: vita_partner, zip_code: zip_code, primary_birth_date: 25.years.ago, primary_ssn: '123456789' }

  before do
    allow(subject).to receive(:current_intake).and_return(intake)
  end

  describe "#edit" do
    let(:id_experiment) { Experiment.find_by(key: ExperimentService::ID_VERIFICATION_EXPERIMENT) }
    let(:returning_client_experiment) { Experiment.find_by(key: ExperimentService::RETURNING_CLIENT_EXPERIMENT) }

    before do
      Experiment.update_all(enabled: true)
      id_experiment.experiment_vita_partners.create(vita_partner: vita_partner)
      returning_client_experiment.experiment_vita_partners.create(vita_partner: vita_partner)
    end

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

    context "ID experiment" do
      context "an intake with a vita partner that is in the experiment" do
        it "assigns the intake to an Id Verification Experiment treatment group" do
          get :edit

          participant = ExperimentParticipant.find_by(experiment: id_experiment, record: intake)
          expect(participant.treatment.to_sym).to be_in(id_experiment.treatment_weights.keys)
        end
      end

      context "an intake with a vita partner that is not in the experiment" do
        before do
          intake.update(vita_partner: create(:organization))
        end

        it "does not put the intake in the experiment" do
          get :edit

          expect(ExperimentParticipant.where(experiment: id_experiment, record: intake)).to be_empty
        end
      end

      context "an intake that is already in the returning client treatment group" do
        before do
          intake.update(matching_previous_year_intake: create(:intake))
          returning_client_treatment_chooser = instance_double(ExperimentService::TreatmentChooser, choose: :skip_identity_documents)
          allow(ExperimentService::TreatmentChooser).to receive(:new).and_call_original
          allow(ExperimentService::TreatmentChooser).to receive(:new).with(ExperimentService::CONFIG[ExperimentService::RETURNING_CLIENT_EXPERIMENT][:treatment_weights]).and_return returning_client_treatment_chooser
        end

        it "does not try to put client in experiment" do
          get :edit

          expect(ExperimentParticipant.where(experiment: id_experiment, record: intake)).to be_empty
        end
      end
    end

    context "returning client experiment" do
      context "the client has a matching prior year client" do
        before do
          intake.update(matching_previous_year_intake: create(:intake))
        end

        context "an intake with a vita partner that is in the experiment" do
          it "assigns the intake to a Returning Client Experiment treatment group" do
            get :edit

            participant = ExperimentParticipant.find_by(experiment: returning_client_experiment, record: intake)
            expect(participant.treatment.to_sym).to be_in(returning_client_experiment.treatment_weights.keys)
          end
        end

        context "an intake with a vita partner that is not in the experiment" do
          before do
            intake.update(vita_partner: create(:organization))
          end

          it "does not put the intake in the experiment" do
            get :edit

            expect(ExperimentParticipant.where(experiment: returning_client_experiment, record: intake)).to be_empty
          end
        end
      end

      context "the client does not have a matching prior year client" do
        it "does not assign the intake to a Returning Client Experiment treatment group" do
          get :edit

          expect(ExperimentParticipant.where(experiment: returning_client_experiment, record: intake)).to be_empty
        end
      end
    end
  end
end
