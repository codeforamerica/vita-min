require 'rails_helper'

describe Efile::Md::Md502rCalculator do
  let(:filing_status) { "single" }
  let(:intake) { create(:state_file_md_intake, filing_status: filing_status) }
  let(:main_calculator) do
    Efile::Md::Md502Calculator.new(
      year: MultiTenantService.statefile.current_tax_year,
      intake: intake
    )
  end
  let(:instance) { main_calculator.instance_variable_get(:@md502r) }

  describe '#calculate_9a' do
    context 'when filing MFJ with positive federal SSB' do
      let(:filing_status) { "married_filing_jointly" }
      before do
        intake.direct_file_data.fed_ssb = 1000
        intake.primary_ssb_amount = 600
        intake.update!(raw_direct_file_data: intake.direct_file_data.to_s)
        main_calculator.calculate
      end

      it 'returns primary SSB amount' do

        expect(instance.lines[:MD502R_LINE_9A].value).to eq 600
      end
    end

    context 'when not filing MFJ or no federal SSB' do
      before do
        intake.direct_file_data.fed_ssb = 1000
      end

      it 'returns federal SSB amount' do
        main_calculator.calculate
        expect(instance.lines[:MD502R_LINE_9A].value).to eq 1000
      end
    end
  end

  describe '#calculate_line_9b' do
    context 'when filing MFJ with positive federal SSB' do
      before do
        allow(intake).to receive(:filing_status_mfj?).and_return(true)
        allow(intake).to receive_message_chain(:direct_file_data, :fed_ssb).and_return(1000)
        allow(intake).to receive(:spouse_ssb_amount).and_return(400)
      end

      it 'returns spouse SSB amount' do
        expect(calculator.send(:calculate_line_9b)).to eq(400)
      end
    end

    context 'when not filing MFJ or no federal SSB' do
      before do
        allow(intake).to receive(:filing_status_mfj?).and_return(false)
        allow(intake).to receive_message_chain(:direct_file_data, :fed_ssb).and_return(0)
      end

      it 'returns nil' do
        expect(calculator.send(:calculate_line_9b)).to be_nil
      end
    end
  end
end


