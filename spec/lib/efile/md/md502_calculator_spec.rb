require 'rails_helper'

describe Efile::Md::Md502Calculator do
  let(:filing_status) { "single" }
  let(:intake) { create(:state_file_md_intake, filing_status: filing_status) }
  let(:instance) do
    described_class.new(
      year: MultiTenantService.statefile.current_tax_year,
      intake: intake
    )
  end

  describe "#calculate_line_1e" do
    let(:filing_status) { "single" }

    context 'when total interest is greater than $11,600' do
      before do
        intake.direct_file_data.fed_taxable_income = 11_599
        intake.direct_file_data.fed_tax_exempt_interest = 2
      end

      it 'returns true' do
        instance.calculate
        expect(instance.lines[:MD502_LINE_1E].value).to be_truthy
      end
    end

    context 'when total interest is less than or equal to $11,600' do
      before do
        intake.direct_file_data.fed_taxable_income = 11_599
        intake.direct_file_data.fed_tax_exempt_interest = 1
      end

      it 'returns true' do
        instance.calculate
        expect(instance.lines[:MD502_LINE_1E].value).to be_falsey
      end
    end
  end

  describe "#calculate_md502_cr_part_b_line_3" do
    before do
      intake.direct_file_data.fed_agi = agi
      instance.calculate
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

      context "the agi is over $103,651" do
        let(:agi) { 103_651 }
        it 'returns the correct decimal value' do
          expect(instance.lines[:MD502CR_PART_B_LINE_3].value).to eq(0.000)
        end
      end
    end

    context "when filer is mfj" do
      let(:filing_status) { "married_filing_jointly" }

      context 'the agi is $62,001' do
        let(:agi) { 62_001 }
        it 'returns the correct decimal value' do
          expect(instance.lines[:MD502CR_PART_B_LINE_3].value).to eq(0.3040)
        end
      end

      context 'the agi is $161,1001' do
        let(:agi) { 161_101 }
        it 'returns the correct decimal value' do
          expect(instance.lines[:MD502CR_PART_B_LINE_3].value).to eq(0.000)
        end
      end
    end
  end

  describe '#calculate_md502_cr_part_b_line_4' do
    let(:filing_status) { "single" }

    before do
      intake.direct_file_data.fed_agi = 10
      intake.direct_file_data.fed_credit_for_child_and_dependent_care_amount = 10
      instance.calculate
    end

    it 'returns the correct decimal value' do
      expect(instance.lines[:MD502CR_PART_B_LINE_4].value).to eq(3)
    end
  end

  describe '#calculate_md502_cr_part_m_line_1' do
    context "when filing status is mfj, qss or hoh" do
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
              instance.calculate
            end
            it "awards a credit of $1750" do
              expect(instance.lines[:MD502CR_PART_M_LINE_1].value).to eq(1_750)
            end
          end
          context "when agi > $150,000" do
            before do
              intake.direct_file_data.fed_agi = 150_001
              instance.calculate
            end
            it "awards no credit" do
              expect(instance.lines[:MD502CR_PART_M_LINE_1].value).to eq(0)
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
              instance.calculate
            end
            it "awards a credit of $1000" do
              expect(instance.lines[:MD502CR_PART_M_LINE_1].value).to eq(1_000)
            end
          end
          context "when agi > $150,000" do
            before do
              intake.direct_file_data.fed_agi = 150_001
              instance.calculate
            end
            it "awards no credit" do
              expect(instance.lines[:MD502CR_PART_M_LINE_1].value).to eq(0)
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
              instance.calculate
            end
            it "awards a credit of $1000" do
              expect(instance.lines[:MD502CR_PART_M_LINE_1].value).to eq(1_000)
            end
          end
          context "when agi > $150,000" do
            before do
              intake.direct_file_data.fed_agi = 150_001
              instance.calculate
            end
            it "awards no credit" do
              expect(instance.lines[:MD502CR_PART_M_LINE_1].value).to eq(0)
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
              instance.calculate
            end
            it "awards no credit" do
              expect(instance.lines[:MD502CR_PART_M_LINE_1].value).to eq(0)
            end
          end
          context "when agi > $150,000" do
            before do
              intake.direct_file_data.fed_agi = 150_001
              instance.calculate
            end
            it "awards no credit" do
              expect(instance.lines[:MD502CR_PART_M_LINE_1].value).to eq(0)
            end
          end
        end
      end
    end
    context "when filing status is single or mfs" do
      let(:filing_status) { "single" }
      context "when filer is 65 or older" do
        before do
          intake.primary_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 65, 1, 1)
        end
        context "when agi <= $100,000" do
          before do
            intake.direct_file_data.fed_agi = 100_000
            instance.calculate
          end
          it "awards a credit of $1750" do
            expect(instance.lines[:MD502CR_PART_M_LINE_1].value).to eq(1_000)
          end
        end
        context "when agi > $100,000" do
          before do
            intake.direct_file_data.fed_agi = 100_001
            instance.calculate
          end
          it "awards no credit" do
            expect(instance.lines[:MD502CR_PART_M_LINE_1].value).to eq(0)
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
            instance.calculate
          end
          it "awards no credit" do
            expect(instance.lines[:MD502CR_PART_M_LINE_1].value).to eq(0)
          end
        end
        context "when agi > $100,000" do
          before do
            intake.direct_file_data.fed_agi = 100_001
            instance.calculate
          end
          it "awards no credit" do
            expect(instance.lines[:MD502CR_PART_M_LINE_1].value).to eq(0)
          end
        end
      end
    end
  end

  context "exemptions" do
    context "dependent exemptions" do
      let(:dependent_count) { 2 }
      before do
        allow_any_instance_of(Efile::Md::Md502bCalculator).to receive(:calculate_line_3).and_return dependent_count
      end

      describe "Dependent exemption count" do
        it "gets line 3 from 502b" do
          instance.calculate
          expect(instance.lines[:MD502_DEPENDENT_EXEMPTION_COUNT].value).to eq dependent_count
        end
      end

      describe "Dependent exemption amount" do
        [
          [["single", "married_filing_separately"], [
            [100_000, 3200],
            [125_000, 1600],
            [150_000, 800],
            [150_001, 0]
          ]],
          [["married_filing_jointly", "qualifying_widow", "head_of_household"], [
            [100_000, 3200],
            [125_000, 3200],
            [150_000, 3200],
            [175_000, 1600],
            [200_000, 800],
            [200_001, 0]
          ]]
        ].each do |filing_statuses, agis_to_deductions|
          filing_statuses.each do |filing_status|
            context "#{filing_status}" do
              let(:intake) { create(:state_file_md_intake, filing_status: filing_status) }
              let(:calculator_instance) { described_class.new(year: MultiTenantService.statefile.current_tax_year, intake: intake) }

              agis_to_deductions.each do |fagi, deduction_amt|
                it "returns the value corresponding to #{fagi} FAGI multiplied by number of dependents" do
                  intake.direct_file_data.fed_agi = fagi

                  calculator_instance.calculate
                  expect(calculator_instance.lines[:MD502_DEPENDENT_EXEMPTION_AMOUNT].value).to eq(deduction_amt * dependent_count)
                end
              end
            end
          end
        end
      end
    end
  end
end
