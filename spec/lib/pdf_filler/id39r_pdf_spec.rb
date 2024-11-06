require 'rails_helper'

RSpec.describe PdfFiller::Id39rPdf do
  include PdfSpecHelper

  let(:intake) { create(:state_file_id_intake) }
  let(:submission) { create(:efile_submission, tax_return: nil, data_source: intake) }
  let(:pdf) { described_class.new(submission) }
  let(:file_path) { described_class.new(submission).output_file.path }
  let(:pdf_fields) { filled_in_values(file_path) }
  let!(:dependents) do
    [
      create(:state_file_dependent, intake: intake, first_name: "Child", last_name: "One", ssn: "123456789", dob: Date.new(2010, 1, 1)),
      create(:state_file_dependent, intake: intake, first_name: "Child", last_name: "Two", ssn: "987654321", dob: Date.new(2012, 2, 2)),
      create(:state_file_dependent, intake: intake, first_name: "Child", last_name: "Three", ssn: "456789123", dob: Date.new(2014, 3, 3)),
      create(:state_file_dependent, intake: intake, first_name: "Child", last_name: "Four", ssn: "321654987", dob: Date.new(2016, 4, 4)),
      create(:state_file_dependent, intake: intake, first_name: "Child", last_name: "Five", ssn: "789123456", dob: Date.new(2018, 5, 5))
    ]
  end

  describe "#hash_for_pdf" do
    let(:pdf_fields) { filled_in_values(submission.generate_filing_pdf.path) }
    it 'uses field names that exist in the pdf' do
      missing_fields = pdf.hash_for_pdf.keys.map(&:to_s) - pdf_fields.keys
      expect(missing_fields).to eq([])
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
        expect(pdf_fields["BL6"]).to eq "200"
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
        expect(pdf_fields["BL6"]).to eq "200"
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
        expect(pdf_fields["BL6"]).to eq "0"
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
        expect(pdf_fields["BL6"]).to eq "200"
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
        expect(pdf_fields["BL6"]).to eq "200"
      end
    end

    context 'when there are more than 4 dependents' do
      let!(:dependents) do
        [
          create(:state_file_dependent, intake: intake, first_name: "Child", last_name: "One", ssn: "123456789", dob: Date.new(2010, 1, 1)),
          create(:state_file_dependent, intake: intake, first_name: "Child", last_name: "Two", ssn: "987654321", dob: Date.new(2012, 2, 2)),
          create(:state_file_dependent, intake: intake, first_name: "Child", last_name: "Three", ssn: "456789123", dob: Date.new(2014, 3, 3)),
          create(:state_file_dependent, intake: intake, first_name: "Child", last_name: "Four", ssn: "321654987", dob: Date.new(2016, 4, 4)),
          create(:state_file_dependent, intake: intake, first_name: "Child", last_name: "Five", ssn: "789123456", dob: Date.new(2018, 5, 5))
        ]
      end
      it 'includes correct dependent information' do
        result = pdf.hash_for_pdf

        expect(result['FR1FirstName']).to eq 'Child'
        expect(result['FR1LastName']).to eq 'Five'
        expect(result['FR1SSN']).to eq '789123456'
        expect(result['FR1Birthdate']).to eq '05/05/2018'

        expect(result['FR2FirstName']).to be_nil
        expect(result['FR2LastName']).to be_nil
        expect(result['FR2SSN']).to be_nil
        expect(result['FR2Birthdate']).to be_nil

        expect(result['FR3FirstName']).to be_nil
        expect(result['FR3LastName']).to be_nil
        expect(result['FR3SSN']).to be_nil
        expect(result['FR3Birthdate']).to be_nil
      end
    end

    context "fills out Total Additions" do
      let(:intake) { create(:state_file_id_intake, :df_data_1099_int) }
      it "correctly fills answers" do
        expect(pdf_fields["AL7"]).to eq "0"
      end
    end

    context "fills out Interest Income from Obligations of the US" do
      let(:intake) { create(:state_file_id_intake, :df_data_1099_int) }
      it "correctly fills answers" do
        expect(pdf_fields["BL3"]).to eq "2"
      end
    end

    context "fills out Health Insurance Premium amount" do
      let(:intake) { create(:state_file_id_intake, has_health_insurance_premium: "yes", health_insurance_paid_amount:  15.30) }
      it "correctly fills answers" do
        expect(pdf_fields["BL18"]).to eq "15"
      end
    end
  end
end
