require 'rails_helper'

describe Efile::Md::Md502crCalculator do
  let(:filing_status) { "single" }
  let(:intake) { create(:state_file_md_intake, filing_status: filing_status) }
  let(:main_calculator) do
    Efile::Md::Md502Calculator.new(
      year: MultiTenantService.statefile.current_tax_year,
      intake: intake
    )
  end
  let(:instance) { main_calculator.instance_variable_get(:@md502cr) }

  describe '#calculate_md502_cr_part_m_line_1' do
    %w[qualifying_widow head_of_household].each do |filing_status|
      context "when filing status is #{filing_status}" do
        let(:filing_status) { filing_status }

        context "when filer is 65 or older" do
          before do
            intake.primary_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 65, 1, 1)
          end

          context "when agi <= $150,000" do
            before do
              intake.direct_file_data.fed_agi = 150_000
              main_calculator.calculate
            end

            it "awards a credit of $1750" do
              expect(instance.lines[:MD502CR_PART_M_LINE_1].value).to eq(1_750)
              expect(instance.lines[:MD502CR_PART_AA_LINE_13].value).to eq(1_750)
            end
          end

          context "when agi > $150,000" do
            before do
              intake.direct_file_data.fed_agi = 150_001
              main_calculator.calculate
            end

            it "awards no credit" do
              expect(instance.lines[:MD502CR_PART_M_LINE_1].value).to eq(0)
              expect(instance.lines[:MD502CR_PART_AA_LINE_13].value).to eq(0)
            end
          end
        end
      end

      context "when filer is under 65" do
        before do
          intake.primary_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 64, 1, 1)
        end

        context "when agi <= $150,000" do
          before do
            intake.direct_file_data.fed_agi = 150_000
            main_calculator.calculate
          end

          it "awards no credit" do
            expect(instance.lines[:MD502CR_PART_M_LINE_1].value).to eq(0)
            expect(instance.lines[:MD502CR_PART_AA_LINE_13].value).to eq(0)
          end
        end

        context "when agi > $150,000" do
          before do
            intake.direct_file_data.fed_agi = 150_001
            main_calculator.calculate
          end

          it "awards no credit" do
            expect(instance.lines[:MD502CR_PART_M_LINE_1].value).to eq(0)
            expect(instance.lines[:MD502CR_PART_AA_LINE_13].value).to eq(0)
          end
        end
      end
    end

    context "when filing status is mfj" do
      let(:filing_status) { "married_filing_jointly" }
      context "when filer is 65 or older" do
        before do
          intake.primary_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 65, 1, 1)
        end

        context "when spouse is 65 or older" do
          before do
            intake.spouse_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 65, 1, 1)
          end

          context "when agi <= $150,000" do
            before do
              intake.direct_file_data.fed_agi = 150_000
              allow(instance).to receive(:deduction_method_is_standard?).and_return(true)
              main_calculator.calculate
            end

            it "awards a credit of $1750" do
              expect(instance.lines[:MD502CR_PART_M_LINE_1].value).to eq(1_750)
              expect(instance.lines[:MD502CR_PART_AA_LINE_13].value).to eq(1_750)
            end

            context "deduction method is nonstandard" do
              before do
                allow(instance).to receive(:deduction_method_is_standard?).and_return(false)
                main_calculator.calculate
              end

              it "awards no credit" do
                expect(instance.lines[:MD502CR_PART_M_LINE_1].value).to eq(0)
              end
            end
          end

          context "when agi > $150,000" do
            before do
              intake.direct_file_data.fed_agi = 150_001
              main_calculator.calculate
            end

            it "awards no credit" do
              expect(instance.lines[:MD502CR_PART_M_LINE_1].value).to eq(0)
              expect(instance.lines[:MD502CR_PART_AA_LINE_13].value).to eq(0)
            end
          end
        end

        context "when spouse is under 65" do
          before do
            intake.spouse_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 64, 1, 1)
          end

          context "when agi <= $150,000" do
            before do
              intake.direct_file_data.fed_agi = 150_000
              main_calculator.calculate
            end

            it "awards a credit of $1000" do
              expect(instance.lines[:MD502CR_PART_M_LINE_1].value).to eq(1_000)
              expect(instance.lines[:MD502CR_PART_AA_LINE_13].value).to eq(1_000)
            end
          end

          context "when agi > $150,000" do
            before do
              intake.direct_file_data.fed_agi = 150_001
              main_calculator.calculate
            end

            it "awards no credit" do
              expect(instance.lines[:MD502CR_PART_M_LINE_1].value).to eq(0)
              expect(instance.lines[:MD502CR_PART_AA_LINE_13].value).to eq(0)
            end
          end
        end
      end

      context "when filer is under 65" do
        before do
          intake.primary_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 64, 1, 1)
        end

        context "when spouse is 65 or older" do
          before do
            intake.spouse_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 65, 1, 1)
          end

          context "when agi <= $150,000" do
            before do
              intake.direct_file_data.fed_agi = 150_000
              main_calculator.calculate
            end

            it "awards a credit of $1000" do
              expect(instance.lines[:MD502CR_PART_M_LINE_1].value).to eq(1_000)
              expect(instance.lines[:MD502CR_PART_AA_LINE_13].value).to eq(1_000)
            end
          end

          context "when agi > $150,000" do
            before do
              intake.direct_file_data.fed_agi = 150_001
              main_calculator.calculate
            end

            it "awards no credit" do
              expect(instance.lines[:MD502CR_PART_M_LINE_1].value).to eq(0)
              expect(instance.lines[:MD502CR_PART_AA_LINE_13].value).to eq(0)
            end
          end
        end

        context "when spouse is under 65" do
          before do
            intake.spouse_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 64, 1, 1)
          end

          context "when agi <= $150,000" do
            before do
              intake.direct_file_data.fed_agi = 150_000
              main_calculator.calculate
            end

            it "awards no credit" do
              expect(instance.lines[:MD502CR_PART_M_LINE_1].value).to eq(0)
              expect(instance.lines[:MD502CR_PART_AA_LINE_13].value).to eq(0)
            end
          end

          context "when agi > $150,000" do
            before do
              intake.direct_file_data.fed_agi = 150_001
              main_calculator.calculate
            end

            it "awards no credit" do
              expect(instance.lines[:MD502CR_PART_M_LINE_1].value).to eq(0)
              expect(instance.lines[:MD502CR_PART_AA_LINE_13].value).to eq(0)
            end
          end
        end
      end
    end

    %w[single married_filing_separately dependent].each do |filing_status|
      context "when filing status is #{filing_status}" do
        if filing_status == "dependent"
          let(:filing_status) { "single" }
          let(:claimed_as_dependent) { true}
        else
          let(:filing_status) { filing_status }
          let(:claimed_as_dependent) { false }
        end

        before do
          allow_any_instance_of(DirectFileData).to receive(:claimed_as_dependent?).and_return claimed_as_dependent
        end

        context "when filer is 65 or older" do
          before do
            intake.primary_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 65, 1, 1)
          end

          context "when agi <= $100,000" do
            before do
              intake.direct_file_data.fed_agi = 100_000
              main_calculator.calculate
            end

            it "awards a credit of $1000" do
              expect(instance.lines[:MD502CR_PART_M_LINE_1].value).to eq(1_000)
              expect(instance.lines[:MD502CR_PART_AA_LINE_13].value).to eq(1_000)
            end
          end

          context "when agi > $100,000" do
            before do
              intake.direct_file_data.fed_agi = 100_001
              main_calculator.calculate
            end

            it "awards no credit" do
              expect(instance.lines[:MD502CR_PART_M_LINE_1].value).to eq(0)
              expect(instance.lines[:MD502CR_PART_AA_LINE_13].value).to eq(0)
            end
          end
        end

        context "when filer is under 65" do
          before do
            intake.primary_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 64, 1, 1)
          end

          context "when agi <= $100,000" do
            before do
              intake.direct_file_data.fed_agi = 100_000
              main_calculator.calculate
            end

            it "awards no credit" do
              expect(instance.lines[:MD502CR_PART_M_LINE_1].value).to eq(0)
              expect(instance.lines[:MD502CR_PART_AA_LINE_13].value).to eq(0)
            end
          end

          context "when agi > $100,000" do
            before do
              intake.direct_file_data.fed_agi = 100_001
              main_calculator.calculate
            end

            it "awards no credit" do
              expect(instance.lines[:MD502CR_PART_M_LINE_1].value).to eq(0)
              expect(instance.lines[:MD502CR_PART_AA_LINE_13].value).to eq(0)
            end
          end
        end
      end
    end

  end

  describe "line 2" do
    before do
      intake.direct_file_data.fed_credit_for_child_and_dependent_care_amount = 30
      instance.calculate
    end

    it "sets the line to the df value" do
      expect(instance.lines[:MD502CR_PART_B_LINE_2].value).to eq(30)
    end
  end

  describe "#calculate_md502_cr_part_b_line_3" do
    before do
      intake.direct_file_data.fed_agi = agi
      main_calculator.calculate
    end

    context "when filer is non-mfj" do
      let(:filing_status) { "single" }

      context "the agi is negative" do
        let(:agi) { -10 }

        it 'returns the correct decimal value' do
          expect(instance.lines[:MD502CR_PART_B_LINE_3].value).to eq(0.32)
        end
      end

      context "the agi is 0" do
        let(:agi) { 0 }

        it 'returns the correct decimal value' do
          expect(instance.lines[:MD502CR_PART_B_LINE_3].value).to eq(0.32)
        end
      end

      context "the agi is 90,001" do
        let(:agi) { 90_001 }

        it 'returns the correct decimal value' do
          expect(instance.lines[:MD502CR_PART_B_LINE_3].value).to eq(0.2208)
        end
      end

      context "the agi is $103,651" do
        let(:agi) { 103_651 }

        it 'returns the correct decimal value' do
          expect(instance.lines[:MD502CR_PART_B_LINE_3].value).to eq(0.1984e0)
        end
      end

      context "the agi is over $107,001" do
        let(:agi) { 107_001 }

        it 'returns the correct decimal value' do
          expect(instance.lines[:MD502CR_PART_B_LINE_3].value).to eq(0.1856e0)
        end
      end
    end

    context "when filer is mfj" do
      let(:intake) { create(:state_file_md_intake, :with_senior_spouse) }

      context 'the agi is $62,001' do
        let(:agi) { 62_001 }

        it 'returns the correct decimal value' do
          expect(instance.lines[:MD502CR_PART_B_LINE_3].value).to eq(0.3040)
        end
      end

      context 'the agi is $167,1001' do
        let(:agi) { 167_101 }

        it 'returns the correct decimal value' do
          expect(instance.lines[:MD502CR_PART_B_LINE_3].value).to eq(0.192e0)
        end
      end
    end
  end

  describe '#calculate_md502_cr_part_b_line_4' do
    let(:filing_status) { "single" }
    let(:fed_agi) { 10 }
    let(:fed_credit_for_child_and_dependent_care_amount) { 10 }

    before do
      intake.direct_file_data.fed_agi = fed_agi
      intake.direct_file_data.fed_credit_for_child_and_dependent_care_amount = fed_credit_for_child_and_dependent_care_amount
      main_calculator.calculate
    end

    context "calculations do not exceed $1344" do
      it 'returns the correct decimal value' do
        expect(instance.lines[:MD502CR_PART_B_LINE_4].value).to eq(3)
        expect(instance.lines[:MD502CR_PART_AA_LINE_2].value).to eq(3)
      end
    end

    context "exceeds $1344 limit" do
      let(:fed_agi) { 98_001 }
      let(:fed_credit_for_child_and_dependent_care_amount) { 10_000 }

      it "should return the limit" do
        expect(instance.lines[:MD502CR_PART_B_LINE_4].value).to eq(1_344)
        expect(instance.lines[:MD502CR_PART_AA_LINE_2].value).to eq(1_344)
      end
    end
  end

  describe 'calculate_part_aa_line_14' do
    before do
      allow_any_instance_of(described_class).to receive(:calculate_part_aa_line_2).and_return(100)
      allow_any_instance_of(described_class).to receive(:calculate_part_aa_line_13).and_return(200)
      instance.calculate
    end

    it "returns the sum of part AA lines 2 and 13" do
      expect(instance.lines[:MD502CR_PART_AA_LINE_14].value).to eq(300)
    end
  end

  describe "#calculate_part_cc_line_7" do
    before do
      intake.direct_file_data.fed_agi = agi
      allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_21).and_return 25
      allow_any_instance_of(described_class).to receive(:calculate_md502_cr_part_b_line_4).and_return 100
      main_calculator.calculate
    end

    context "when filing_status is not mfj" do
      %w[single married_filing_separately head_of_household qualifying_widow dependent].each do |filing_status|
        context "when #{filing_status} filer" do
          let(:filing_status) { filing_status }

          context "when AGI is within limit" do
            let(:agi) { 59_400 }
            it "returns difference between part B line 4 and line 21" do
              instance.calculate
              expect(instance.lines[:MD502CR_PART_CC_LINE_7].value).to eq(75)
            end
          end

          context "when AGI exceeds limit" do
            let(:agi) { 59_401 }
            it "returns nil" do
              instance.calculate
              expect(instance.lines[:MD502CR_PART_CC_LINE_7].value).to be_nil
            end
          end
        end
      end
    end


    context "when married filing jointly" do
      let(:filing_status) { "married_filing_jointly" }

      context "when AGI is within limit" do
        let(:agi) { 89_100 }
        it "returns difference between part B line 4 and line 21" do
          instance.calculate
          expect(instance.lines[:MD502CR_PART_CC_LINE_7].value).to eq(75)
        end
      end

      context "when AGI exceeds limit" do
        let(:agi) { 89_101 }
        it "returns nil" do
          expect(instance.lines[:MD502CR_PART_CC_LINE_7].value).to be_nil
        end
      end
    end
  end

  describe 'calculate_part_cc_line_8' do
    before do
      intake.direct_file_data.fed_agi = agi
      instance.calculate
    end

    context "when has an agi below 15,000 and has 2 qualifying children" do
      let!(:intake) { create(:state_file_md_intake, :with_dependents) }
      let(:agi) { 9_102 }

      it 'calculates to 1000' do
        expect(instance.lines[:MD502CR_PART_CC_LINE_8].value).to eq(1000)
      end
    end

    context "when has an agi above 15,000 and has 2 qualifying children" do
      let!(:intake) { create(:state_file_md_intake, :with_dependents) }
      let(:agi) { 19_102 }

      it 'calculates to 1000' do
        expect(instance.lines[:MD502CR_PART_CC_LINE_8].value).to be_nil
      end
    end

    context "when has an agi below 15,000 and there is no qualifying children" do
      let(:agi) { 9_102 }

      it 'calculates to 1000' do
        expect(instance.lines[:MD502CR_PART_CC_LINE_8].value).to eq(0)
      end
    end
  end

  describe 'calculate_part_cc_line_10' do
    before do
      allow_any_instance_of(described_class).to receive(:calculate_part_cc_line_7).and_return(100)
      allow_any_instance_of(described_class).to receive(:calculate_part_cc_line_8).and_return(200)
      instance.calculate
    end

    it "returns the sum of part cc lines 1-9" do
      expect(instance.lines[:MD502CR_PART_CC_LINE_10].value).to eq(300)
    end
  end
end
