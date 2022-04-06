require 'rails_helper'

describe "backfill_triage_data:intake_triage_fields" do
  include_context "rake"

  around do |example|
    capture_output { example.run }
  end

  context "triage with no intake" do
    let!(:triage_without_intake) { create :triage }

    it "does not modify it" do
      expect {
        task.invoke
      }.not_to change { triage_without_intake }
    end
  end

  context "triage needs itin help" do
    let!(:triage) { create :triage, intake: create(:intake, triage_filing_status: 'unfilled'), id_type: "need_itin_help" }

    it "copies answer to Intake#need_itin_help" do
      task.invoke

      triage.reload
      expect(triage.intake.need_itin_help).to eq "yes"
    end
  end

  context "income level" do
    let!(:triage) { create :triage, intake: create(:intake, triage_filing_status: 'unfilled'), income_level: "12500_to_25000" }

    it "copies answer to Intake#triage_income_level" do
      task.invoke

      triage.reload
      expect(triage.intake.triage_income_level).to eq "12500_to_25000"
    end
  end

  context "filing frequency" do
    context "every_year" do
      let!(:triage) {
        create(
          :triage, intake: create(:intake, triage_filing_status: 'unfilled'),
          filed_2018: "yes",
          filed_2019: "yes",
          filed_2020: "yes",
          filed_2021: "yes"
        )
      }

      it "copies answer to Intake#triage_filing_frequency" do
        task.invoke

        triage.reload
        expect(triage.intake.triage_filing_frequency).to eq "every_year"
      end
    end

    context "some_years" do
      let!(:triage) {
        create(
          :triage, intake: create(:intake, triage_filing_status: 'unfilled'),
          filed_2018: "yes",
          filed_2019: "yes",
          filed_2020: "no",
          filed_2021: "no"
        )
      }

      it "copies answer to Intake#triage_filing_frequency" do
        task.invoke

        triage.reload
        expect(triage.intake.triage_filing_frequency).to eq "some_years"
      end
    end

    context "not_filed" do
      let!(:triage) {
        create(
          :triage, intake: create(:intake, triage_filing_status: 'unfilled'),
          filed_2018: "no",
          filed_2019: "no",
          filed_2020: "no",
          filed_2021: "no"
        )
      }

      it "copies answer to Intake#triage_filing_frequency" do
        task.invoke

        triage.reload
        expect(triage.intake.triage_filing_frequency).to eq "not_filed"
      end
    end

    context "unfilled" do
      let!(:triage) {
        create(
          :triage, intake: create(:intake, triage_filing_status: 'unfilled'),
          filed_2018: "unfilled",
          filed_2019: "unfilled",
          filed_2020: "unfilled",
          filed_2021: "unfilled"
        )
      }

      it "copies answer to Intake#triage_filing_frequency" do
        task.invoke

        triage.reload
        expect(triage.intake.triage_filing_frequency).to eq "unfilled"
      end
    end
  end

  context "filing status" do
    let!(:triage) { create :triage, intake: create(:intake, triage_filing_status: 'unfilled'), filing_status: "single" }

    it "copies answer to Intake#triage_filing_status" do
      task.invoke

      triage.reload
      expect(triage.intake.triage_filing_status).to eq "single"
    end
  end

  context "income ineligible" do
    context "at least one of income_type_rent or income_type_farm is yes" do
      let!(:triage) { create :triage, intake: create(:intake, triage_filing_status: 'unfilled'), income_type_rent: "yes" }

      it "sets Intake#triage_vita_income_ineligible to yes" do
        task.invoke

        triage.reload
        expect(triage.intake.triage_vita_income_ineligible).to eq "yes"
      end
    end

    context "both income_type_rent and income_type_farm are no" do
      let!(:triage) { create :triage, intake: create(:intake, triage_filing_status: 'unfilled'), income_type_rent: "no", income_type_farm: "no" }

      it "sets Intake#triage_vita_income_ineligible to unfilled" do
        task.invoke

        triage.reload
        expect(triage.intake.triage_vita_income_ineligible).to eq "no"
      end
    end

    context "either is unfilled" do
      let!(:triage) { create :triage, intake: create(:intake, triage_filing_status: 'unfilled'), income_type_rent: "unfilled" }

      it "sets Intake#triage_vita_income_ineligible to unfilled" do
        task.invoke

        triage.reload
        expect(triage.intake.triage_vita_income_ineligible).to eq "unfilled"
      end
    end
  end
end
