require 'rails_helper'

describe SubmissionBuilder::Ty2024::States::Id::Documents::Id39R, required_schema: "id" do
  describe ".document" do
    let(:intake) { create(:state_file_id_intake) }
    let(:submission) { create(:efile_submission, data_source: intake) }
    let(:build_response) { described_class.build(submission, validate: false) }
    let(:xml) { Nokogiri::XML::Document.parse(build_response.document.to_xml) }

    context "filer with income document" do
      let(:intake) { create(:state_file_id_intake, :df_data_1099_int) }
      it "correctly fills answers" do
        expect(xml.at("TotalAdditions")&.text).to eq "0"
        expect(xml.at("IncomeUSObligations")&.text).to eq "2"
        expect(xml.at("PensionFilingStatusAmount")&.text).to eq "0"
        expect(xml.at("RailroadRetirement")&.text).to eq "0"
        expect(xml.at("SocialSecurityBenefits")&.text).to eq "0"
        expect(xml.at("PensionExclusions")&.text).to eq "0"
        expect(xml.at("RetirementBenefitsDeduction")&.text).to eq "0"
        expect(xml.at("HealthInsurancePaid")&.text).to eq "0"
        expect(xml.at("TotalSubtractions")&.text).to eq "2"
      end
    end

    context "TotalSubtractions" do
      before do
        allow_any_instance_of(Efile::Id::Id39RCalculator).to receive(:calculate_sec_b_line_3).and_return 1
        allow_any_instance_of(Efile::Id::Id39RCalculator).to receive(:calculate_sec_b_line_6).and_return 2
        allow_any_instance_of(Efile::Id::Id39RCalculator).to receive(:calculate_sec_b_line_7).and_return 3
        # line 8f is part of the calculation but it's always 0 for now
        allow_any_instance_of(Efile::Id::Id39RCalculator).to receive(:calculate_sec_b_line_18).and_return 4
      end

      it "should add up all the subtractions" do
        expect(xml.at('TotalSubtractions')&.text).to eq "10"
      end
    end

    context "TxblSSAndRRBenefits" do
      context "with taxable social security benefit" do
        before do
          intake.direct_file_data.fed_taxable_ssb = 225
        end

        it "correctly fills answers" do
          expect(xml.at("TxblSSAndRRBenefits").text).to eq "225"
        end
      end

      context "without taxable social security benefit" do
        before do
          intake.direct_file_data.fed_taxable_ssb = nil
        end

        it "correctly fills answers" do
          expect(xml.at("TxblSSAndRRBenefits").text).to eq "0"
        end
      end
    end

    describe "child care credit amount" do
      context "when TotalQlfdExpensesOrLimitAmt is least" do
        before do
          intake.direct_file_data.total_qualifying_dependent_care_expenses = 200
          intake.direct_file_data.excluded_benefits_amount = 500
          intake.direct_file_data.primary_earned_income_amount = 500
          intake.direct_file_data.spouse_earned_income_amount = 500
        end

        it 'should expect to fill with qualified expenses amount' do
          expect(xml.document.at('ChildCareCreditAmt')&.text).to eq "200"
        end
      end

      context "when ExcludedBenefitsAmt is least after subtracting from 12,000" do
        before do
          intake.direct_file_data.total_qualifying_dependent_care_expenses = 500
          intake.direct_file_data.excluded_benefits_amount = 11_800
          intake.direct_file_data.primary_earned_income_amount = 500
          intake.direct_file_data.spouse_earned_income_amount = 500
        end

        it 'should expect to fill with excluded benefits amount' do
          expect(xml.document.at('ChildCareCreditAmt')&.text).to eq "200"
        end
      end

      context "when ExcludedBenefitsAmt is greater than 12,000" do
        before do
          intake.direct_file_data.total_qualifying_dependent_care_expenses = 500
          intake.direct_file_data.excluded_benefits_amount = 12_800
          intake.direct_file_data.primary_earned_income_amount = 500
          intake.direct_file_data.spouse_earned_income_amount = 500
        end

        it 'should expect to fill with excluded benefits amount' do
          expect(xml.document.at('ChildCareCreditAmt')&.text).to eq "0"
        end
      end

      context "when PrimaryEarnedIncomeAmt is least" do
        before do
          intake.direct_file_data.total_qualifying_dependent_care_expenses = 500
          intake.direct_file_data.excluded_benefits_amount = 500
          intake.direct_file_data.primary_earned_income_amount = 200
          intake.direct_file_data.spouse_earned_income_amount = 500
        end

        it 'should expect to fill with primary earned income amount' do
          expect(xml.document.at('ChildCareCreditAmt')&.text).to eq "200"
        end
      end

      context "when SpouseEarnedIncomeAmt is least" do
        before do
          intake.direct_file_data.total_qualifying_dependent_care_expenses = 500
          intake.direct_file_data.excluded_benefits_amount = 500
          intake.direct_file_data.primary_earned_income_amount = 500
          intake.direct_file_data.spouse_earned_income_amount = 200
        end

        it 'should expect to fill with primary earned income amount' do
          expect(xml.document.at('ChildCareCreditAmt')&.text).to eq "200"
        end
      end
    end
  end
end
