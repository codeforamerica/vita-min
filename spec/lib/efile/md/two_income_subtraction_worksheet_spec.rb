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
    context "primary and spouse have only w2 income" do
      let(:intake) { create(:state_file_md_intake, :df_data_many_w2s) }
      it "calculates the fed income amount for primary and spouse" do
        expect(instance.calculate_fed_income(:primary)).to eq(150_000)
        expect(instance.calculate_fed_income(:spouse)).to eq(50_000)
      end
    end

    context "primary and spouse have only interest income" do
      before do
        intake.direct_file_data.spouse_ssn = "987654321"
        intake.update!(raw_direct_file_data: intake.direct_file_data.to_s)
      end
      let(:intake) { create(:state_file_md_intake, :df_data_1099_int_with_spouse) }
      it "calculates the fed income amount for primary and spouse" do
        expect(instance.calculate_fed_income(:primary)).to eq(4)
        expect(instance.calculate_fed_income(:spouse)).to eq(140)
      end
    end

    context "primary and spouse have only retirement income" do
      before do
        intake.direct_file_data.w2_nodes.each do |w2_node| w2_node.content = nil end
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
        intake.direct_file_data.w2_nodes.each do |w2_node| w2_node.content = nil end
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
    context "no fed subtractions" do
      it "calculates the fed subtraction amount for primary and spouse" do
        expect(instance.calculate_fed_subtractions(:primary)).to eq(0)
        expect(instance.calculate_fed_subtractions(:spouse)).to eq(0)
      end
    end
  end

  describe "#calculate_line_1" do
    before do
      instance.calculate
      intake.synchronize_df_w2s_to_database
    end

    context "primary and spouse have only w2 income" do
      let(:intake) { create(:state_file_md_intake, :with_spouse, :df_data_many_w2s) }
      it "calculates the fed income amount for primary and spouse" do
        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_1_A].value).to eq(150_000)
        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_1_B].value).to eq(50_000)
      end
    end
  end

  describe "#calculate_line_2" do
    before do
      instance.calculate
    end

    context "no state additions" do
      it "calculates the state addition amount for primary and spouse" do
        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_2_A].value).to eq(0)
        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_2_B].value).to eq(0)
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
    before do
      instance.calculate
    end

    context "no state subtractions" do
      it "calculates the state subtraction amount for primary and spouse" do
        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_4_A].value).to eq(0)
        expect(instance.lines[:MD_TWO_INCOME_WK_LINE_4_B].value).to eq(0)
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
