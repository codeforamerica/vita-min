require "rails_helper"

describe TriagePrepareSoloForm do
  subject { described_class.new(params) }
  let(:will_prepare) { "yes" }
  let(:params) do
    {
        will_prepare: will_prepare
    }
  end
  context "an instance" do
    it "responds to #will_prepare" do
      expect(subject).to respond_to :will_prepare
    end
  end

  describe "#will_prepare?" do
    context "will_prepare is yes" do
      it "is true" do
        expect(subject.will_prepare?).to eq true
      end
    end

    context "will_prepare is no" do
      let(:will_prepare) { "no" }
      it "is false" do
        expect(subject.will_prepare?).to eq false
      end
    end
  end
end