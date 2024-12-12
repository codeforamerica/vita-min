require 'rails_helper'

describe Efile::Md::TwoIncomeSubtractionWorksheet do
  let(:intake) { create(:state_file_md_intake, :with_spouse) }
  let(:main_calculator) do
    Efile::Md::Md502Calculator.new(
      year: MultiTenantService.statefile.current_tax_year,
      intake: intake
    )
  end
  let(:instance) { main_calculator.instance_variable_get(:@two_income_subtraction_worksheet) }

  describe "#calculate_fed_income" do
    context "primary and spouse have no income" do
      it "calculates the fed income amount for primary and spouse" do
        expect(instance.calculate_fed_income(:primary)).to eq(0)
        expect(instance.calculate_fed_income(:spouse)).to eq(0)
      end
    end

    context "primary and spouse have only wage income" do
      let(:intake) { create(:state_file_md_intake, :df_data_many_w2s) }
      it "calculates the fed income amount for primary and spouse" do
        expect(instance.calculate_fed_income(:primary)).to eq(50_000 + 50_000 + 50_000)
        expect(instance.calculate_fed_income(:spouse)).to eq(50_000)
      end
    end

    context "primary and spouse have only interest income" do
      before do
        primary_ssn = intake.primary.ssn
        spouse_ssn = intake.spouse.ssn
        # only populating minimum data required for this test
        intake.raw_direct_file_intake_data["interestReports"] = [{}, {}, {}, {}]
        intake.direct_file_json_data.interest_reports[0].recipient_tin = primary_ssn
        intake.direct_file_json_data.interest_reports[1].recipient_tin = primary_ssn
        intake.direct_file_json_data.interest_reports[2].recipient_tin = spouse_ssn
        intake.direct_file_json_data.interest_reports[3].recipient_tin = spouse_ssn
      end

      it "calculates the fed income amount for primary and spouse from multiple interest reports" do
        intake.direct_file_json_data.interest_reports[0].amount_1099 = "10.00"
        intake.direct_file_json_data.interest_reports[1].amount_1099 = "20.00"
        intake.direct_file_json_data.interest_reports[2].amount_no_1099 = "30.00"
        intake.direct_file_json_data.interest_reports[3].amount_no_1099 = "40.00"
        expect(instance.calculate_fed_income(:primary)).to eq(10 + 20)
        expect(instance.calculate_fed_income(:spouse)).to eq(30 + 40)
      end

      it "handles nil values for interest income" do
        intake.direct_file_json_data.interest_reports[0].amount_1099 = nil
        intake.direct_file_json_data.interest_reports[1].amount_no_1099 = nil
        intake.direct_file_json_data.interest_reports[2].amount_1099 = nil
        intake.direct_file_json_data.interest_reports[3].amount_no_1099 = nil
        expect(instance.calculate_fed_income(:primary)).to eq(0)
        expect(instance.calculate_fed_income(:spouse)).to eq(0)
      end
    end

    context "primary and spouse have only retirement income" do
      let(:primary_ssn) { intake.primary.ssn }
      let(:spouse_ssn) { intake.spouse.ssn }
      let!(:primary_state_file1099_r_1) { create(:state_file1099_r, intake: intake, recipient_ssn: primary_ssn, taxable_amount: 10) }
      let!(:primary_state_file1099_r_2) { create(:state_file1099_r, intake: intake, recipient_ssn: primary_ssn, taxable_amount: 20) }
      let!(:spouse_state_file1099_r_1) { create(:state_file1099_r, intake: intake, recipient_ssn: spouse_ssn, taxable_amount: 30) }
      let!(:spouse_state_file1099_r_2) { create(:state_file1099_r, intake: intake, recipient_ssn: spouse_ssn, taxable_amount: 40) }

      it "calculates the fed income amount for primary and spouse from multiple 1099Rs" do
        expect(instance.calculate_fed_income(:primary)).to eq(10 + 20)
        expect(instance.calculate_fed_income(:spouse)).to eq(30 + 40)
      end
    end

    context "primary and spouse have only unemployment income" do
      it "calculates the fed income amount for primary and spouse" do
        intake.direct_file_json_data.primary_filer&.form_1099_gs_total = "100.00"
        intake.direct_file_json_data.spouse_filer&.form_1099_gs_total = "200.00"
        expect(instance.calculate_fed_income(:primary)).to eq(100)
        expect(instance.calculate_fed_income(:spouse)).to eq(200)
      end
    end

    context "primary and spouse have all four kinds of income" do
      let(:intake) { create(:state_file_md_intake, :df_data_many_w2s) }
      let(:primary_ssn) { intake.primary.ssn }
      let(:spouse_ssn) { intake.spouse.ssn }
      let!(:primary_state_file1099_r) { create(:state_file1099_r, intake: intake, recipient_ssn: primary_ssn, taxable_amount: 10) }
      let!(:spouse_state_file1099_r) { create(:state_file1099_r, intake: intake, recipient_ssn: spouse_ssn, taxable_amount: 20) }

      before do
        # only populating minimum data required for this test
        intake.raw_direct_file_intake_data["interestReports"] = [{}, {}]
        intake.direct_file_json_data.interest_reports[0].recipient_tin = primary_ssn
        intake.direct_file_json_data.interest_reports[1].recipient_tin = spouse_ssn
        intake.direct_file_json_data.interest_reports[0].amount_1099 = "1.00"
        intake.direct_file_json_data.interest_reports[1].amount_no_1099 = "2.00"
        intake.direct_file_json_data.primary_filer&.form_1099_gs_total = "100.00"
        intake.direct_file_json_data.spouse_filer&.form_1099_gs_total = "200.00"
      end

      it "calculates the fed income amount for primary and spouse" do
        expect(instance.calculate_fed_income(:primary)).to eq(50_000 + 50_000 + 50_000 + 100 + 10 + 1)
        expect(instance.calculate_fed_income(:spouse)).to eq(50_000 + 200 + 20 + 2)
      end
    end
  end

  describe "#calculate_fed_subtractions" do
    context "primary and spouse have only student loan interest subtractions" do
      it "calculates the fed subtraction amount for primary and spouse" do
        intake.update(primary_student_loan_interest_ded_amount: 1.1)
        intake.update(spouse_student_loan_interest_ded_amount: 2.2)
        expect(instance.calculate_fed_subtractions(:primary)).to eq(1)
        expect(instance.calculate_fed_subtractions(:spouse)).to eq(2)
      end
    end

    context "primary and spouse have only educator expense subtractions" do
      it "calculates the fed subtraction amount for primary and spouse" do
        intake.direct_file_json_data.primary_filer&.educator_expenses = "10.00"
        intake.direct_file_json_data.spouse_filer&.educator_expenses = "20.00"
        expect(instance.calculate_fed_subtractions(:primary)).to eq(10)
        expect(instance.calculate_fed_subtractions(:spouse)).to eq(20)
      end
    end

    context "primary and spouse have only health savings account subtractions" do
      it "calculates the fed subtraction amount for primary and spouse" do
        intake.direct_file_json_data.primary_filer&.hsa_total_deductible_amount = "100.00"
        intake.direct_file_json_data.spouse_filer&.hsa_total_deductible_amount = "200.00"
        expect(instance.calculate_fed_subtractions(:primary)).to eq(100)
        expect(instance.calculate_fed_subtractions(:spouse)).to eq(200)
      end
    end

    context "primary and spouse have all three kinds of subtractions" do
      it "calculates the fed subtraction amount for primary and spouse" do
        intake.update(primary_student_loan_interest_ded_amount: 1)
        intake.update(spouse_student_loan_interest_ded_amount: 2)
        intake.direct_file_json_data.primary_filer&.educator_expenses = "10.00"
        intake.direct_file_json_data.spouse_filer&.educator_expenses = "20.00"
        intake.direct_file_json_data.primary_filer&.hsa_total_deductible_amount = "100.00"
        intake.direct_file_json_data.spouse_filer&.hsa_total_deductible_amount = "200.00"
        expect(instance.calculate_fed_subtractions(:primary)).to eq(100 + 10 + 1)
        expect(instance.calculate_fed_subtractions(:spouse)).to eq(200 + 20 + 2)
      end
    end
  end

  describe "#calculate_line_1" do
    context "calculating federal agi" do
      it "calculates a positive fed agi for primary and spouse" do
        allow_any_instance_of(described_class).to receive(:calculate_fed_income) do |_, primary_or_spouse|
          case primary_or_spouse
          when :primary
            100
          when :spouse
            200
          end
        end
        allow_any_instance_of(described_class).to receive(:calculate_fed_subtractions) do |_, primary_or_spouse|
          case primary_or_spouse
          when :primary
            10
          when :spouse
            20
          end
        end
        instance.calculate

        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_1_A].value).to eq(100 - 10)
        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_1_B].value).to eq(200 - 20)
      end

      it "calculates a negative fed agi for primary and spouse" do
        allow_any_instance_of(described_class).to receive(:calculate_fed_income) do |_, primary_or_spouse|
          case primary_or_spouse
          when :primary
            100
          when :spouse
            200
          end
        end
        allow_any_instance_of(described_class).to receive(:calculate_fed_subtractions) do |_, primary_or_spouse|
          case primary_or_spouse
          when :primary
            110
          when :spouse
            220
          end
        end
        instance.calculate

        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_1_A].value).to eq(100 - 110)
        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_1_B].value).to eq(200 - 220)
      end

      it "calculates a 0 fed agi for primary and spouse" do
        allow_any_instance_of(described_class).to receive(:calculate_fed_income) do |_, primary_or_spouse|
          case primary_or_spouse
          when :primary
            100
          when :spouse
            200
          end
        end
        allow_any_instance_of(described_class).to receive(:calculate_fed_subtractions) do |_, primary_or_spouse|
          case primary_or_spouse
          when :primary
            100
          when :spouse
            200
          end
        end
        instance.calculate

        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_1_A].value).to eq(0)
        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_1_B].value).to eq(0)
      end
    end
  end

  describe "#calculate_line_2" do
    context "no state additions" do
      it "calculates the state addition amount for primary and spouse" do
        instance.calculate
        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_2_A].value).to eq(0)
        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_2_B].value).to eq(0)
      end
    end

    context "primary and spouse have STPICKUP" do
      let!(:primary_ssn) { intake.primary.ssn }
      let!(:spouse_ssn) { intake.spouse.ssn }
      let!(:primary_state_file_w2) { create(:state_file_w2, state_file_intake: intake, employee_ssn: primary_ssn, box14_stpickup: 100.1) }
      let!(:spouse_state_file_w2) { create(:state_file_w2, state_file_intake: intake, employee_ssn: spouse_ssn, box14_stpickup: 199.9) }
      it "calculates the state addition amount for primary and spouse" do
        instance.calculate
        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_2_A].value).to eq(100)
        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_2_B].value).to eq(200)
      end
    end
  end

  describe "#calculate_line_3" do
    context "calculating federal agi plus state additions" do
      it "calculates a positive amount for primary and spouse" do
        allow_any_instance_of(described_class).to receive(:calculate_line_1) do |_, primary_or_spouse|
          case primary_or_spouse
          when :primary
            100
          when :spouse
            200
          end
        end
        allow_any_instance_of(described_class).to receive(:calculate_line_2) do |_, primary_or_spouse|
          case primary_or_spouse
          when :primary
            10
          when :spouse
            20
          end
        end
        instance.calculate

        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_3_A].value).to eq(100 + 10)
        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_3_B].value).to eq(200 + 20)
      end

      it "calculates a negative amount for primary and spouse" do
        allow_any_instance_of(described_class).to receive(:calculate_line_1) do |_, primary_or_spouse|
          case primary_or_spouse
          when :primary
            -100
          when :spouse
            -200
          end
        end
        allow_any_instance_of(described_class).to receive(:calculate_line_2) do |_, primary_or_spouse|
          case primary_or_spouse
          when :primary
            10
          when :spouse
            20
          end
        end
        instance.calculate

        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_3_A].value).to eq(-100 + 10)
        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_3_B].value).to eq(-200 + 20)
      end

      it "calculates a 0 for primary and spouse" do
        allow_any_instance_of(described_class).to receive(:calculate_line_1) do |_, primary_or_spouse|
          case primary_or_spouse
          when :primary
            -100
          when :spouse
            -200
          end
        end
        allow_any_instance_of(described_class).to receive(:calculate_line_2) do |_, primary_or_spouse|
          case primary_or_spouse
          when :primary
            100
          when :spouse
            200
          end
        end
        instance.calculate

        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_3_A].value).to eq(-100 + 100)
        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_3_B].value).to eq(-200 + 200)
      end
    end
  end

  describe "#calculate_line_4" do
    context "no state subtractions" do
      it "calculates the state subtraction amount for primary and spouse" do
        instance.calculate
        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_4_A].value).to eq(0)
        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_4_B].value).to eq(0)
      end
    end

    context "return has qualifying dependent care expenses subtraction" do
      before do
        intake.direct_file_data.total_qualifying_dependent_care_expenses_or_limit = 200
      end

      it "calculates the state subtraction amount for primary and spouse" do
        instance.calculate
        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_4_A].value).to eq(100)
        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_4_B].value).to eq(100)
      end
    end
  end

  describe "#calculate_line_5" do
    context "calculating federal agi plus state additions, minus state subtractions" do
      it "calculates a positive amount for primary and spouse" do
        allow_any_instance_of(described_class).to receive(:calculate_line_3) do |_, primary_or_spouse|
          case primary_or_spouse
          when :primary
            100
          when :spouse
            200
          end
        end
        allow_any_instance_of(described_class).to receive(:calculate_line_4) do |_, primary_or_spouse|
          case primary_or_spouse
          when :primary
            10
          when :spouse
            20
          end
        end
        instance.calculate

        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_5_A].value).to eq(100 - 10)
        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_5_B].value).to eq(200 - 20)
      end

      it "calculates a negative amount for primary and spouse" do
        allow_any_instance_of(described_class).to receive(:calculate_line_3) do |_, primary_or_spouse|
          case primary_or_spouse
          when :primary
            100
          when :spouse
            200
          end
        end
        allow_any_instance_of(described_class).to receive(:calculate_line_4) do |_, primary_or_spouse|
          case primary_or_spouse
          when :primary
            110
          when :spouse
            220
          end
        end
        instance.calculate

        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_5_A].value).to eq(100 - 110)
        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_5_B].value).to eq(200 - 220)
      end

      it "calculates a 0 for primary and spouse" do
        allow_any_instance_of(described_class).to receive(:calculate_line_3) do |_, primary_or_spouse|
          case primary_or_spouse
          when :primary
            100
          when :spouse
            200
          end
        end
        allow_any_instance_of(described_class).to receive(:calculate_line_4) do |_, primary_or_spouse|
          case primary_or_spouse
          when :primary
            100
          when :spouse
            200
          end
        end
        instance.calculate

        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_5_A].value).to eq(0)
        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_5_B].value).to eq(0)
      end
    end
  end

  describe "#calculate_line_6" do
    context "returning the lower income" do
      it "returns an income greater than 1_200" do
        allow_any_instance_of(described_class).to receive(:calculate_line_5) do |_, primary_or_spouse|
          case primary_or_spouse
          when :primary
            1_201
          when :spouse
            1_202
          end
        end
        instance.calculate

        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_6].value).to eq(1_201)
      end

      it "returns an income between 1200 and 0" do
        allow_any_instance_of(described_class).to receive(:calculate_line_5) do |_, primary_or_spouse|
          case primary_or_spouse
          when :primary
            1_201
          when :spouse
            1_000
          end
        end
        instance.calculate

        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_6].value).to eq(1_000)
      end

      it "returns 0 if the lower income is below 0" do
        allow_any_instance_of(described_class).to receive(:calculate_line_5) do |_, primary_or_spouse|
          case primary_or_spouse
          when :primary
            1_201
          when :spouse
            -1
          end
        end
        instance.calculate

        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_6].value).to eq(0)
      end
    end
  end

  describe "#calculate_line_7" do
    context "returning the final subtraction amount" do
      it "returns the lower income amount when line 6 is within the limit" do
        allow_any_instance_of(described_class).to receive(:calculate_line_6).and_return(1_000)
        instance.calculate

        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_7].value).to eq(1_000)
      end

      it "returns the maximum subtraction amount when line 6 is greater than the limit" do
        allow_any_instance_of(described_class).to receive(:calculate_line_6).and_return(1_201)
        instance.calculate

        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_7].value).to eq(1_200)
      end

      it "returns the minimum subtraction amount when line 6 is less than the limit" do
        allow_any_instance_of(described_class).to receive(:calculate_line_6).and_return(-1)
        instance.calculate

        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_7].value).to eq(0)
      end
    end
  end
end
