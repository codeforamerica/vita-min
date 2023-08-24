require 'rails_helper'

describe IdVerificationExperimentService do
  describe "#document_type_options" do
    context "the intake is in the ID Verification experiment" do
      let(:intake){ create :intake }
      let(:experiment) { Experiment.find_by(key: ExperimentService::ID_VERIFICATION_EXPERIMENT) }
      let(:treatment) { "expanded_id" }
      let(:subject) { described_class.new(intake) }

      before do
        Experiment.update_all(enabled: true)
        create :experiment_participant, experiment: experiment, record: intake, treatment: treatment
      end

      context "has a treatment of expanded_id" do
        it "includes expanded id types" do
          expect(subject.document_type_options).to include DocumentTypes::SecondaryIdentification::Form1099
        end
      end

      context "has a treatment of control" do
        let(:treatment) { "control" }

        it "does not includes expanded id types" do
          expect(subject.document_type_options).not_to include DocumentTypes::SecondaryIdentification::Form1099
        end
      end
    end
  end
end
