require 'rails_helper'

describe Efile::Md::Md502SuCalculator do
  let(:intake) { create(:state_file_md_intake) }
  let(:main_calculator) do
    Efile::Md::Md502Calculator.new(
      year: MultiTenantService.statefile.current_tax_year,
      intake: intake
    )
  end
  let(:instance) { main_calculator.instance_variable_get(:@md502_su) }

  describe 'line ab' do
    before do
      instance.calculate
    end

    context 'without interest reports' do
      it 'does not set line ab' do
        expect(instance.lines[:MD502_SU_LINE_AB].value).to eq(0)
      end
    end

    context 'with interest report' do
      let(:intake) { create(:state_file_md_intake, :df_data_1099_int) }
      it 'sets line ab' do
        expect(instance.lines[:MD502_SU_LINE_AB].value).to eq(2)
      end
    end
  end

  describe 'line 1' do
    it 'totals lines a through yc' do
      allow(instance).to receive(:calculate_line_ab).and_return 100
      instance.calculate
      expect(instance.lines[:MD502_SU_LINE_1].value).to eq(100)
    end
  end
end
