require "rails_helper"

RSpec.describe TriageIncomeLevelForm do
  let(:intake) { create :intake }
  let(:income_level) { "1_to_12500" }
  let(:filing_status) { "single" }
  let(:filing_frequency) { "some_years" }
  let(:vita_income_ineligible) { "yes" }
  let(:params) do
    {
      triage_filing_status: filing_status,
      triage_income_level: income_level,
      triage_filing_frequency: filing_frequency,
      triage_vita_income_ineligible: vita_income_ineligible,
    }
  end

  describe "validations" do
    describe '#triage_income_level' do
      context 'when params include a bad income level value' do
        let(:income_level) { "other" }

        it "does not pass validation" do
          form = described_class.new(intake, params)
          expect(form).not_to be_valid
          expect(form.errors[:triage_income_level]).to be_present
        end
      end

      context "when params includes an empty value for income" do
        let(:income_level) { nil }

        it "does not pass validation" do
          form = described_class.new(intake, params)
          expect(form).not_to be_valid
          expect(form.errors[:triage_income_level]).to be_present
        end
      end

      context "when params includes a valid value for income" do
        let(:income_level) { "1_to_12500" }

        it "passes validation" do
          expect(described_class.new(intake, params)).to be_valid
        end
      end
    end

    describe "#triage_filing_status" do
      context 'when params include a bad value' do
        let(:filing_status) { "other" }

        it "does not pass validation" do
          form = described_class.new(intake, params)
          expect(form).not_to be_valid
          expect(form.errors[:triage_filing_status]).to be_present
        end
      end

      context "when params includes an empty value" do
        let(:filing_status) { nil }

        it "does not pass validation" do
          form = described_class.new(intake, params)
          expect(form).not_to be_valid
          expect(form.errors[:triage_filing_status]).to be_present
        end
      end

      context "when params includes a valid value" do
        let(:filing_status) { "jointly" }

        it "passes validation" do
          expect(described_class.new(intake, params)).to be_valid
        end
      end
    end

    describe "#triage_filing_frequency" do
      context 'when params include a bad value' do
        let(:filing_frequency) { "other" }

        it "does not pass validation" do
          form = described_class.new(intake, params)
          expect(form).not_to be_valid
          expect(form.errors[:triage_filing_frequency]).to be_present
        end
      end

      context "when params includes an empty value" do
        let(:filing_frequency) { nil }

        it "does not pass validation" do
          form = described_class.new(intake, params)
          expect(form).not_to be_valid
          expect(form.errors[:triage_filing_frequency]).to be_present
        end
      end

      context "when params includes a valid value" do
        let(:filing_frequency) { "some_years" }

        it "passes validation" do
          expect(described_class.new(intake, params)).to be_valid
        end
      end
    end

    describe "#triage_vita_income_ineligible" do
      context 'when params include a bad value' do
        let(:vita_income_ineligible) { "other" }

        it "does not pass validation" do
          form = described_class.new(intake, params)
          expect(form).not_to be_valid
          expect(form.errors[:triage_vita_income_ineligible]).to be_present
        end
      end

      context "when params includes an empty value" do
        let(:vita_income_ineligible) { nil }

        it "does not pass validation" do
          form = described_class.new(intake, params)
          expect(form).not_to be_valid
          expect(form.errors[:triage_vita_income_ineligible]).to be_present
        end
      end

      context "when params includes a valid value" do
        let(:vita_income_ineligible) { "no" }

        it "passes validation" do
          expect(described_class.new(intake, params)).to be_valid
        end
      end
    end
  end

  describe "#save" do
    let(:intake) { create :intake }
    let(:params) do
      {
        triage_filing_status: "single",
        triage_income_level: "1_to_12500",
        triage_filing_frequency: "some_years",
        triage_vita_income_ineligible: "yes",
      }
    end

    it "updates the intake" do
      described_class.new(intake, params).save

      intake.reload
      expect(intake.triage_filing_status).to eq "single"
      expect(intake.triage_income_level).to eq "1_to_12500"
      expect(intake.triage_filing_frequency).to eq "some_years"
      expect(intake.triage_vita_income_ineligible).to eq "yes"
    end
  end
end
