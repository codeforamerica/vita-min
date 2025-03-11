require 'rails_helper'

RSpec.describe PdfFiller::Id39rPdf do
  include PdfSpecHelper
  let(:primary_first_name) { "Helena"}
  let(:primary_last_name) { "Eagan" }
  let(:intake) { create(:state_file_id_intake, primary_first_name: primary_first_name, primary_last_name: primary_last_name) }
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

  before do
    allow(Flipper).to receive(:enabled?).and_call_original
    allow(Flipper).to receive(:enabled?).with(:show_retirement_ui).and_return(true)
  end

  describe "#hash_for_pdf" do
    let(:pdf_fields) { filled_in_values(submission.generate_filing_pdf.path) }
    it 'uses field names that exist in the pdf' do
      missing_fields = pdf.hash_for_pdf.keys.map(&:to_s) - pdf_fields.keys
      expect(missing_fields).to eq([])
    end
  end

  describe "child care credit amount" do
    context "when sum of QualifiedCareExpensesPaidAmts is least" do
      before do
        allow(intake.direct_file_data).to receive(:total_qualifying_dependent_care_expenses_no_limit).and_return(200)
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
        allow(intake.direct_file_data).to receive(:total_qualifying_dependent_care_expenses_no_limit).and_return(500)
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
        allow(intake.direct_file_data).to receive(:total_qualifying_dependent_care_expenses_no_limit).and_return(500)
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
        allow(intake.direct_file_data).to receive(:total_qualifying_dependent_care_expenses_no_limit).and_return(500)
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
        allow(intake.direct_file_data).to receive(:total_qualifying_dependent_care_expenses_no_limit).and_return(500)
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

    context "fills out Total Additions and Interest Income from Obligations of the US" do
      let(:intake) { create(:state_file_id_intake, :df_data_1099_int) }
      it "correctly fills answers" do
        expect(pdf_fields["AL7"]).to eq "0"
        expect(pdf_fields["BL3"]).to eq "50"
      end
    end

    context "fills out Health Insurance Premium amount" do
      let(:intake) { create(:state_file_id_intake, has_health_insurance_premium: "yes", health_insurance_paid_amount:  15.30) }
      it "correctly fills answers" do
        expect(pdf_fields["BL18"]).to eq "15"
      end
    end

    context "subtractions" do
      before do
        allow_any_instance_of(Efile::Id::Id39RCalculator).to receive(:calculate_sec_b_line_3).and_return 1
        allow_any_instance_of(Efile::Id::Id39RCalculator).to receive(:calculate_sec_b_line_6).and_return 2
        allow_any_instance_of(Efile::Id::Id39RCalculator).to receive(:calculate_sec_b_line_7).and_return 3
        allow_any_instance_of(Efile::Id::Id39RCalculator).to receive(:calculate_sec_b_line_8a).and_return 100
        allow_any_instance_of(Efile::Id::Id39RCalculator).to receive(:calculate_sec_b_line_8c).and_return 200
        allow_any_instance_of(Efile::Id::Id39RCalculator).to receive(:calculate_sec_b_line_8d).and_return 300
        allow_any_instance_of(Efile::Id::Id39RCalculator).to receive(:calculate_sec_b_line_8e).and_return 400
        allow_any_instance_of(Efile::Id::Id39RCalculator).to receive(:calculate_sec_b_line_8f).and_return 500
        allow_any_instance_of(Efile::Id::Id39RCalculator).to receive(:calculate_sec_b_line_18).and_return 4
      end

      it "should show the values for the section" do
        expect(pdf_fields["BL3"]).to eq "1"
        expect(pdf_fields["BL6"]).to eq "2"
        expect(pdf_fields["BL7"]).to eq "3"
        expect(pdf_fields["BL8a"]).to eq "100"
        expect(pdf_fields["BL8c"]).to eq "200"
        expect(pdf_fields["BL8d"]).to eq "300"
        expect(pdf_fields["BL8e"]).to eq "400"
        expect(pdf_fields["BL8f"]).to eq "500"
        expect(pdf_fields["BL18"]).to eq "4"
        expect(pdf_fields["BL24"]).to eq "510"
      end
    end

    context "supplemental credits" do
      it "should always returns 0" do
        expect(pdf_fields["DL4"]).to eq "0"
      end
    end
  end

  describe "Names and SSN" do
    let(:spouse_first_name) { "mark" }
    let(:spouse_last_name) { "scout" }

    context "when non-mfj" do
      it "shows the primary's first and last name" do
        expect(pdf_fields["Names"]).to eq("Helena Eagan")
        expect(pdf_fields["SSN"]).to eq("555002222")
      end
    end

    context "when mfj" do
      let(:intake) {
        create(:state_file_id_intake,
               :with_spouse,
               filing_status: :married_filing_jointly,
               primary_first_name: primary_first_name,
               primary_last_name: primary_last_name,
               spouse_first_name: spouse_first_name,
               spouse_last_name: spouse_last_name)
      }
      context "when last name is the same" do
        let(:spouse_last_name) { "eagan" }
        it "only shows one last name" do
          expect(pdf_fields["Names"]).to eq("Helena & Mark Eagan")
          expect(pdf_fields["SSN"]).to eq("555002222")
        end
      end

      context "when last name is different" do
        it "shows both last names" do
          expect(pdf_fields["Names"]).to eq("Helena Eagan & Mark Scout")
          expect(pdf_fields["SSN"]).to eq("555002222")
        end
      end
    end
  end
end
