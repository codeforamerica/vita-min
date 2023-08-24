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
