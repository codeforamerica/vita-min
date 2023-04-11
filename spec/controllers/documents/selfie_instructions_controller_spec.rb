require "rails_helper"

RSpec.describe Documents::SelfieInstructionsController do
  let(:attributes) { {} }
  let(:intake) { create :intake }

  before do
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
end
