require "rails_helper"

describe TriageResultService do
  let(:subject) { described_class.new(triage)}

  describe "#after_income_levels" do
    context "when the income level makes them eligible only for DIY" do
      let(:triage) { build(:triage, income_level: "unfilled", filing_status: "unfilled") }

      it "redirects to /triage/referral" do
        %w[single jointly].each do |filing_status|
          triage.update(filing_status: filing_status)
          %w[40000_to_65000 65000_to_73000].each do |income_level|
            triage.update(income_level: income_level)

            expect(subject.after_income_levels).to eq(Questions::TriageReferralController.to_path_helper)
          end
        end
      end
    end

    context "when the income level makes them ineligible for any service" do
      let(:triage) { build(:triage, income_level: "over_73000", filing_status: "jointly") }

      it "redirects to /triage/do-not-qualify" do
        %w[single jointly].each do |filing_status|
          triage.update(filing_status: filing_status)

          expect(subject.after_income_levels).to eq(Questions::TriageDoNotQualifyController.to_path_helper)
        end
      end
    end

    # temporary income-only triage
    context "when the income level makes them eligible for full service" do
      let(:triage) { build(:triage, income_level: "unfilled") }

      it "redirects to /triage/do-not-qualify" do
        %w[single jointly].each do |filing_status|
          triage.update(filing_status: filing_status)
          %w[zero 1_to_12500 12500_to_25000 25000_to_40000].each do |income_level|
            triage.update(income_level: income_level)

            expect(subject.after_income_levels).to eq(Questions::TriageGyrController.to_path_helper)
          end
        end
      end
    end
  end

  xdescribe "#after_backtaxes_years" do
    context "with triage answers that are within the filing limit and with at least some documents and with SSN/ITIN paperwork and they need help with any non-2021 year" do
      %w[all_copies some_copies does_not_apply].each do |doc_type|
        context "with doc_type=#{doc_type}" do
          let(:triage) do
            create(
              :triage,
              id_type: "have_id",
              income_level: "hh_1_to_25100",
              doc_type: doc_type,
              filed_2018: "yes",
              filed_2019: "no",
              filed_2020: "no",
              filed_2021: "no",
            )
          end

          it "redirects to full service" do
            expect(subject.after_backtaxes_years).to eq(Questions::TriageGyrController.to_path_helper)
          end
        end
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
