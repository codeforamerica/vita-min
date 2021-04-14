require "rails_helper"

describe TriageTaxNeedsForm do
  let(:file_this_year) { "no" }
  let(:file_previous_years) { "no" }
  let(:collect_stimulus) { "no" }
  subject { described_class.new(params) }

  let(:params) do
    {
      file_this_year: file_this_year,
      file_previous_years: file_previous_years,
      collect_stimulus: collect_stimulus
    }
  end

  context "an instance" do
    it "responds to #file_this_year" do
      expect(subject).to respond_to(:file_this_year)
    end

    it "responds to #file_previous_years" do
      expect(subject).to respond_to(:file_previous_years)
    end

    it "responds to #collect_stimulus" do
      expect(subject).to respond_to(:collect_stimulus)
    end
  end

  describe "#valid?" do
    context "when every attribute is no" do
      it "adds an error to the form object" do
        expect(subject.valid?).to eq false
        expect(subject.errors).to include :at_least_one_selection
      end
    end
  end

  describe "#stimulus_only?" do
    context "when only collect_stimulus is yes" do
      let(:collect_stimulus) { "yes" }
      it "is true" do
        expect(subject.stimulus_only?).to eq true
      end
    end

    context "when other attributes are yes in addition to collect stimulus" do
      let(:collect_stimulus) { "yes" }
      let(:file_previous_years) { "yes" }
      it "is false" do
        expect(subject.stimulus_only?).to eq false
      end
    end

    context "when collect stimulus is no" do
      let(:collect_stimulus) { "no" }
      it "is false" do
        expect(subject.stimulus_only?).to eq false
      end
    end
  end
end