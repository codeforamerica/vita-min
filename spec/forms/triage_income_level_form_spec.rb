require "rails_helper"

RSpec.describe TriageIncomeLevelForm do
  let(:income_level) { "1_to_12500" }
  let(:params) do
    {
        filing_status: "single",
        income_level: income_level,
        source: "example_source",
        referrer: "http://boop.horse/mane",
        locale: "en",
        visitor_id: "visitor_42",
    }
  end
  describe "validations" do
    context 'when params include a bad income level value' do
      let(:income_level) { "other" }
      it "does not pass validation" do
        expect(described_class.new(nil, params)).not_to be_valid
      end
    end

    context "when params includes an empty value for income" do
      let(:income_level) { nil }
      it "does not pass validation" do
        expect(described_class.new(nil, params)).not_to be_valid
      end
    end

    context "when params includes a valid value for income" do
      let(:income_level) { "1_to_12500" }
      it "passes validation" do
        expect(described_class.new(nil, params)).to be_valid
      end
    end
  end

  describe "#save" do
    let(:params) do
      {
        filing_status: "single",
        income_level: "1_to_12500",
        source: "example_source",
        referrer: "http://boop.horse/mane",
        locale: "en",
        visitor_id: "visitor_42",
      }
    end

    it "creates a new triage" do
      expect {
        described_class.new(nil, params).save
      }.to change(Triage, :count).by(1)

      triage = Triage.last
      expect(triage.filing_status).to eq "single"
      expect(triage.income_level).to eq "1_to_12500"
      expect(triage.source).to eq "example_source"
      expect(triage.referrer).to eq "http://boop.horse/mane"
      expect(triage.locale).to eq "en"
      expect(triage.visitor_id).to eq("visitor_42")
    end
  end
end
