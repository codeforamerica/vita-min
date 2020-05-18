require "rails_helper"

RSpec.describe Questions::StimulusRecommendationController do
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

  describe "#show?" do
    context "when the user is filing_for_stimulus and already_filed" do
      it "returns true" do
        expect(subject.class.show?(intake)).to eq true
      end
    end

    context "when the user did not file this year" do
      let(:already_filed) { "no" }
      it "returns false" do
        expect(subject.class.show?(intake)).to eq false
      end
    end

    context "when the user is not filing_for_stimulus" do
      let(:filing_for_stimulus) { "no" }
      it "returns false" do
        expect(subject.class.show?(intake)).to eq false
      end
    end
  end
end

