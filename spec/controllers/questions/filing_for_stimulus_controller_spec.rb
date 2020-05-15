require "rails_helper"

RSpec.describe Questions::FilingForStimulusController do
  let(:intake) do
    create :intake,
      filing_for_stimulus: filing_for_stimulus,
      already_filed: already_filed
  end
  let(:filing_for_stimulus) { "yes" }
  let(:already_filed) { "yes" }

  before do
    allow(subject).to receive(:current_intake).and_return intake
  end

  describe "#next_path" do
    context "when the user is filing_for_stimulus and already_filed" do
      it "returns the stimulus recommendation page" do
        expect(subject.next_path).to eq stimulus_recommendation_path
      end
    end

    context "when the user did not file this year" do
      let(:already_filed) { "no" }
      it "returns the default next navigation path" do
        expect(subject.next_path).to eq backtaxes_questions_path
      end
    end

    context "when the user is not filing_for_stimulus" do
      let(:filing_for_stimulus) { "no" }
      it "returns the default next navigation path" do
        expect(subject.next_path).to eq backtaxes_questions_path
      end
    end
  end
end

