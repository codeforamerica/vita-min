require 'rails_helper'

describe Efile::Md::Md502RCalculator do
  let(:filing_status) { "single" }
  let(:intake) { create(:state_file_md_intake, :df_data_2_w2s, filing_status: filing_status) } # df_data_2_w2s has $8000 in federal social security benefits
  let(:main_calculator) do
    Efile::Md::Md502Calculator.new(
      year: MultiTenantService.statefile.current_tax_year,
      intake: intake
    )
  end
  let(:instance) { main_calculator.instance_variable_get(:@md502r) }

  describe '#calculate_9a' do
    context 'when filing MFJ with positive federal social security benefits' do
      let(:filing_status) { "married_filing_jointly" }
      before do
        intake.primary_ssb_amount = 600.32
        main_calculator.calculate
      end

      it 'returns primary social security benefits amount from the intake' do
        expect(instance.lines[:MD502R_LINE_9A].value).to eq 600
      end
    end

    context 'when filing MFJ without positive federal social security benefits' do
      let(:filing_status) { "married_filing_jointly" }
      let(:intake) { create(:state_file_md_intake, filing_status: filing_status) }

      it 'returns primary social security benefits amount from the intake' do
        main_calculator.calculate
        expect(instance.lines[:MD502R_LINE_9A].value).to eq 0
      end
    end

    context 'when not filing MFJ' do
      it 'returns federal social security benefits amount from 1040' do
        main_calculator.calculate
        expect(instance.lines[:MD502R_LINE_9A].value).to eq 8000
      end
    end
  end

  describe '#calculate_line_9b' do
    context 'when filing MFJ with positive federal social security benefits' do
      let(:filing_status) { "married_filing_jointly" }
      before do
        intake.spouse_ssb_amount = 400.34
        main_calculator.calculate
      end

      it 'returns spouse social security benefits amount from the intake' do
        expect(instance.lines[:MD502R_LINE_9B].value).to eq 400
      end
    end

    context 'when not filing MFJ' do
      it 'returns nil' do
        main_calculator.calculate
        expect(instance.lines[:MD502R_LINE_9B].value).to eq nil
      end
    end
  end
end


