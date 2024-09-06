require 'rails_helper'

describe Efile::Nj::Nj1040 do
  let(:intake) { create(:state_file_nj_intake) }
  let(:instance) do
    described_class.new(
      year: MultiTenantService.statefile.current_tax_year,
      intake: intake
    )
  end

  describe '#calculate_line_6' do
    context 'when filer has no spouse' do
      before do
        intake.direct_file_data.filing_status = 1 # single
        instance.calculate
      end
      it { expect(instance.lines[:NJ1040_LINE_6].value).to eq(1000) }
    end

    context 'when filer has a spouse' do
      let(:intake) { create(:state_file_nj_intake, :married) }
      before do
        instance.calculate
      end
      it { expect(instance.lines[:NJ1040_LINE_6].value).to eq(2000) }
    end
  end

  describe '#calculate_line_7' do
    context 'when filer has no spouse,' do
      context 'when filer is older than 65' do
        before do
          intake.primary_birth_date = Date.new(1900, 1, 1)
          instance.calculate
        end
        it 'sets the self checkbox correctly' do
          expect(instance.lines[:NJ1040_LINE_7_SELF].value).to eq(true)
        end

        it 'sets the spouse checkbox correctly' do
          expect(instance.lines[:NJ1040_LINE_7_SPOUSE].value).to eq(false)
        end

        it 'calculates total line 7 exemption amount correctly' do
          expect(instance.lines[:NJ1040_LINE_7].value).to eq(1000)
        end
      end

      context 'when filer is younger than 65' do
        before do
          intake.primary_birth_date = Date.new(2000, 1, 1)
          instance.calculate
        end
        it 'sets the self checkbox correctly' do
          expect(instance.lines[:NJ1040_LINE_7_SELF].value).to eq(false)
        end

        it 'sets the spouse checkbox correctly' do
          expect(instance.lines[:NJ1040_LINE_7_SPOUSE].value).to eq(false)
        end

        it 'calculates total line 7 exemption amount correctly' do
          expect(instance.lines[:NJ1040_LINE_7].value).to eq(0)
        end
      end
    end

    context 'when filer has a spouse,' do
      let(:intake) { create(:state_file_nj_intake, :married) }
      context 'when filer is older than 65 and spouse is older than 65' do
        let(:intake) { create(:state_file_nj_intake, :married_spouse_over_65, :self_over_65) }
        before do
          instance.calculate
        end
        it 'sets the self checkbox correctly' do
          expect(instance.lines[:NJ1040_LINE_7_SELF].value).to eq(true)
        end

        it 'sets the spouse checkbox correctly' do
          expect(instance.lines[:NJ1040_LINE_7_SPOUSE].value).to eq(true)
        end

        it 'calculates total line 7 exemption amount correctly' do
          expect(instance.lines[:NJ1040_LINE_7].value).to eq(2000)
        end
      end

      context 'when filer is younger than 65 and spouse is older than 65' do
        let(:intake) { create(:state_file_nj_intake, :married_spouse_over_65) }
        before do
          instance.calculate
        end
        it 'sets the self checkbox correctly' do
          expect(instance.lines[:NJ1040_LINE_7_SELF].value).to eq(false)
        end

        it 'sets the spouse checkbox correctly' do
          expect(instance.lines[:NJ1040_LINE_7_SPOUSE].value).to eq(true)
        end

        it 'calculates total line 7 exemption amount correctly' do
          expect(instance.lines[:NJ1040_LINE_7].value).to eq(1000)
        end
      end

      context 'when filer is older than 65 and spouse is younger than 65' do
        let(:intake) { create(:state_file_nj_intake, :married, :self_over_65) }
        before do
          instance.calculate
        end
        it 'sets the self checkbox correctly' do
          expect(instance.lines[:NJ1040_LINE_7_SELF].value).to eq(true)
        end

        it 'sets the spouse checkbox correctly' do
          expect(instance.lines[:NJ1040_LINE_7_SPOUSE].value).to eq(false)
        end

        it 'calculates total line 7 exemption amount correctly' do
          expect(instance.lines[:NJ1040_LINE_7].value).to eq(1000)
        end
      end

      context 'when filer is younger than 65 and spouse is younger than 65' do
        let(:intake) { create(:state_file_nj_intake, :married) }
        before do
          instance.calculate
        end
        it 'sets the self checkbox correctly' do
          expect(instance.lines[:NJ1040_LINE_7_SELF].value).to eq(false)
        end

        it 'sets the spouse checkbox correctly' do
          expect(instance.lines[:NJ1040_LINE_7_SPOUSE].value).to eq(false)
        end

        it 'calculates total line 7 exemption amount correctly' do
          expect(instance.lines[:NJ1040_LINE_7].value).to eq(0)
        end
      end
    end
  end
end
