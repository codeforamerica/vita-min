require "rails_helper"

describe TriageBacktaxesForm do
  let(:filed_previous_years) { "yes" }
  let(:params) do
    {
        filed_previous_years: filed_previous_years
    }
  end

  subject { described_class.new(params) }

  context 'an instance' do

    it "responds to #filed_previous_years" do
      expect(subject).to respond_to :filed_previous_years
    end
  end

  context "#filed_previous_years?" do
    context "when filed_previous_years params is yes" do
      it "returns true" do
        expect(subject.filed_previous_years?).to eq true
      end
    end

    context "when filed_previous_years param is no" do
      let(:filed_previous_years) { "no" }
      it "returns false" do
        expect(subject.filed_previous_years?).to eq false
      end
    end
  end
end