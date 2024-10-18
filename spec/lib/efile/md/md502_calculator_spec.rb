require 'rails_helper'

describe Efile::Md::Md502Calculator do
  let(:intake) { create(:state_file_md_intake, filing_status: "single") }
  let(:instance) do
    described_class.new(
      year: MultiTenantService.statefile.current_tax_year,
      intake: intake
    )
  end

  describe "#calculate_line_1e" do
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
