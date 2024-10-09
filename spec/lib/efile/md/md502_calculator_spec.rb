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

end
