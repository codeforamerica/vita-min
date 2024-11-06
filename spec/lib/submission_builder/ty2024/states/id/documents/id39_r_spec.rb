require 'rails_helper'

describe SubmissionBuilder::Ty2024::States::Id::Documents::Id39R, required_schema: "id" do
  describe ".document" do
    let(:intake) { create(:state_file_id_intake) }
    let(:submission) { create(:efile_submission, data_source: intake) }
    let(:build_response) { described_class.build(submission, validate: false) }
    let(:xml) { Nokogiri::XML::Document.parse(build_response.document.to_xml) }

    context "fills out Interest Income from Obligations of the US" do
      let(:intake) { create(:state_file_id_intake, :df_data_1099_int) }
      it "correctly fills answers" do
        expect(xml.at("IncomeUSObligations").text).to eq "2"
        expect(xml.at("HealthInsurancePaid").text).to eq "0"
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
