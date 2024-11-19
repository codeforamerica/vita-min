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
    context "primary and spouse have only wage income" do
      let(:intake) { create(:state_file_md_intake, :df_data_many_w2s) }
      it "calculates the fed income amount for primary and spouse" do
        expect(instance.calculate_fed_income(:primary)).to eq(150_000)
        expect(instance.calculate_fed_income(:spouse)).to eq(50_000)
      end
    end

    context "primary and spouse have only interest income" do
      before do
        intake.direct_file_data.spouse_ssn = intake.direct_file_json_data.spouse_filer&.tin&.delete("-")
      end
      let(:intake) { create(:state_file_md_intake, :df_data_1099_int_with_spouse) }
      it "calculates the fed income amount for primary and spouse" do
        expect(instance.calculate_fed_income(:primary)).to eq(4)
        expect(instance.calculate_fed_income(:spouse)).to eq(140)
      end
    end

    context "primary and spouse have only retirement income" do
      before do
        intake.direct_file_data.w2_nodes.each do |w2_node|
          w2_node.content = nil
        end
        intake.update!(raw_direct_file_data: intake.direct_file_data.to_s)
      end
      let(:primary_ssn) { intake.primary.ssn }
      let(:spouse_ssn) { intake.spouse.ssn }
      let!(:primary_state_file1099_r) { create(:state_file1099_r, intake: intake, recipient_ssn: primary_ssn, taxable_amount: 100) }
      let!(:spouse_state_file1099_r) { create(:state_file1099_r, intake: intake, recipient_ssn: spouse_ssn, taxable_amount: 200) }

      it "calculates the fed income amount for primary and spouse" do
        expect(instance.calculate_fed_income(:primary)).to eq(100)
        expect(instance.calculate_fed_income(:spouse)).to eq(200)
      end
    end

    context "primary and spouse have only unemployment income" do
      before do
        intake.direct_file_data.w2_nodes.each do |w2_node|
          w2_node.content = nil
        end
        intake.update!(raw_direct_file_data: intake.direct_file_data.to_s)
      end
      let!(:primary_state_file1099_g) { create(:state_file1099_g, intake: intake, recipient: :primary, unemployment_compensation_amount: 600) }
      let!(:spouse_state_file1099_g) { create(:state_file1099_g, intake: intake, recipient: :spouse, unemployment_compensation_amount: 400) }
      it "calculates the fed income amount for primary and spouse" do
        expect(instance.calculate_fed_income(:primary)).to eq(600)
        expect(instance.calculate_fed_income(:spouse)).to eq(400)
      end
    end
  end

  describe "#calculate_fed_subtractions" do
    let(:intake) { create(:state_file_md_intake, :with_spouse) }
    before do
      intake.direct_file_data.primary_ssn = intake.direct_file_json_data.primary_filer&.tin&.delete("-")
      intake.direct_file_data.spouse_ssn = intake.direct_file_json_data.spouse_filer&.tin&.delete("-")
    end

    context "primary and spouse have only student loan interest subtractions" do
      it "calculates the fed subtraction amount for primary and spouse" do
        intake.update(primary_student_loan_interest_ded_amount: 1.1)
        intake.update(spouse_student_loan_interest_ded_amount: 2.2)
        expect(instance.calculate_fed_subtractions(:primary)).to eq(1)
        expect(instance.calculate_fed_subtractions(:spouse)).to eq(2)
      end
    end

    context "primary and spouse have only educator expense subtractions" do
      before do
        intake.direct_file_json_data.primary_filer&.educator_expenses = "10.00"
        intake.direct_file_json_data.spouse_filer&.educator_expenses = "20.00"
      end

      it "calculates the fed subtraction amount for primary and spouse" do
        expect(instance.calculate_fed_subtractions(:primary)).to eq(10)
        expect(instance.calculate_fed_subtractions(:spouse)).to eq(20)
      end
    end

    context "primary and spouse have only health savings account subtractions" do
      before do
        intake.direct_file_json_data.primary_filer&.hsa_total_deductible_amount = "100.00"
        intake.direct_file_json_data.spouse_filer&.hsa_total_deductible_amount = "200.00"
      end

      it "calculates the fed subtraction amount for primary and spouse" do
        expect(instance.calculate_fed_subtractions(:primary)).to eq(100)
        expect(instance.calculate_fed_subtractions(:spouse)).to eq(200)
      end
    end

    context "primary and spouse have all three kinds of subtractions" do
      before do
        intake.direct_file_json_data.primary_filer&.educator_expenses = "10.00"
        intake.direct_file_json_data.spouse_filer&.educator_expenses = "20.00"
        intake.direct_file_json_data.primary_filer&.hsa_total_deductible_amount = "100.00"
        intake.direct_file_json_data.spouse_filer&.hsa_total_deductible_amount = "200.00"
      end

      it "calculates the fed subtraction amount for primary and spouse" do
        intake.update(primary_student_loan_interest_ded_amount: 1)
        intake.update(spouse_student_loan_interest_ded_amount: 2)
        expect(instance.calculate_fed_subtractions(:primary)).to eq(111)
        expect(instance.calculate_fed_subtractions(:spouse)).to eq(222)
      end
    end
  end

  describe "#calculate_line_1" do
    before do
      instance.calculate
      intake.synchronize_df_w2s_to_database
    end

    context "primary and spouse have only w2 income" do
      it "calculates the fed income amount for primary and spouse" do
        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_1_A].value).to eq(9_000)
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
      let!(:primary_state_file_w2) { create(:state_file_w2, state_file_intake: intake, employee_ssn: primary_ssn, box14_stpickup: 100.0) }
      let!(:spouse_state_file_w2) { create(:state_file_w2, state_file_intake: intake, employee_ssn: spouse_ssn, box14_stpickup: 200.0) }
      it "calculates the state addition amount for primary and spouse" do
        instance.calculate
        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_2_A].value).to eq(100)
        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_2_B].value).to eq(200)
      end
    end
  end

  describe "#calculate_line_3" do
    before do
      instance.calculate
    end

    context "no fed income, no fed subtractions, no state additions" do
      it "adds state additions to current amount" do
        # allow_any_instance_of(Efile::Md::TwoIncomeSubtractionWorksheet).to receive(:calculate_line_1).and_return 1
        # allow_any_instance_of(Efile::Md::TwoIncomeSubtractionWorksheet).to receive(:calculate_line_2).and_return 2

        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_3_A].value).to eq(9_000)
        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_3_B].value).to eq(0)
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
        intake.direct_file_data.total_qualifying_dependent_care_expenses = 200
      end

      it "calculates the state subtraction amount for primary and spouse" do
        instance.calculate
        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_4_A].value).to eq(100)
        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_4_B].value).to eq(100)
      end
    end
  end

  describe "#calculate_line_5" do
    before do
      instance.calculate
    end

    context "no fed income, no fed subtractions, no state additions" do
      it "subtracts state subtractions from current amount" do
        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_5_A].value).to eq(9_000)
        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_5_B].value).to eq(0)
      end
    end
  end

  describe "#calculate_line_6" do
    before do
      instance.calculate
    end

    context "no agi" do
      it "returns the lower agi of the two filers" do
        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_6].value).to eq(0)
      end
    end
  end

  describe "#calculate_line_7" do
    before do
      instance.calculate
    end

    context "no agi" do
      it "returns the maximum subtraction amount" do
        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_7].value).to eq(0)
      end
    end
  end
end
