require "rails_helper"

describe TriageResultService do
  let(:subject) { described_class.new(triage)}

  describe "#after_income_levels" do
    context "when the income level makes them eligible only for DIY" do
      let(:triage) { build(:triage, income_level: "hh_66000_to_73000") }

      it "redirects to /triage/referral" do
        expect(subject.after_income_levels).to eq(Questions::TriageReferralController.to_path_helper)
      end
    end

    context "when the income level makes them ineligible" do
      let(:triage) { build(:triage, income_level: "hh_over_73000") }

      it "redirects to /triage/do-not-qualify" do
        expect(subject.after_income_levels).to eq(Questions::TriageDoNotQualifyController.to_path_helper)
      end
    end
  end

  describe "#after_backtaxes_years" do
    context "with triage answers that are within the filing limit and with at least some documents and with SSN/ITIN paperwork and they need help with any non-2021 year" do
      let(:triage) do
        create(
          :triage,
          id_type: "have_paperwork",
          income_level: "hh_1_to_25100",
          doc_type: "some_copies",
          filed_2018: "yes",
          filed_2019: "no",
          filed_2020: "no",
          filed_2021: "no",
        )
      end

      it "redirects to start of full service" do
        expect(subject.after_backtaxes_years).to eq(Questions::TriageIncomeTypesController.to_path_helper)
      end
    end

    context "with triage answers that do not have any documents and they need help with any non-2021 year" do
      let(:triage) do
        create(
          :triage,
          income_level: "hh_1_to_25100",
          doc_type: "need_help",
          filed_2018: "yes",
          filed_2019: "no",
          filed_2020: "no",
          filed_2021: "no",
        )
      end

      it "redirects to the next page in the flow" do
        expect(subject.after_backtaxes_years).to be_nil
      end
    end

    context "with triage answers that do not have SSN/ITIN paperwork and they need help with any non-2021 year" do
      let(:triage) do
        create(
          :triage,
          id_type: "know_number",
          income_level: "hh_1_to_25100",
          doc_type: "some_copies",
          filed_2018: "yes",
          filed_2019: "no",
          filed_2020: "no",
          filed_2021: "no",
        )
      end

      it "redirects to the next page in the flow" do
        expect(subject.after_backtaxes_years).to be_nil
      end
    end
  end
end
