require 'rails_helper'

describe Efile::Nj::Nj1040 do
  let(:intake) { create(:state_file_nj_intake) }
  let(:instance) do
    described_class.new(
      year: MultiTenantService.statefile.current_tax_year,
      intake: intake
    )
  end

  context 'when filing status is single' do
    it "sets line 6 to 1000" do
      instance.calculate
      expect(instance.lines[:NJ1040_LINE_6].value).to eq(1000)
    end

    context 'when filer is older than 65' do
      before do
        intake.primary_birth_date = Date.new(1900, 1, 1)
        instance.calculate
      end
      it 'checks the self 65+ checkbox and sets line 7 to 1000' do
        expect(instance.lines[:NJ1040_LINE_7_SELF].value).to eq(true)
        expect(instance.lines[:NJ1040_LINE_7_SPOUSE].value).to eq(false)
        expect(instance.lines[:NJ1040_LINE_7].value).to eq(1000)
      end
    end

    context 'when filer is younger than 65' do
      before do
        intake.primary_birth_date = Date.new(2000, 1, 1)
        instance.calculate
      end
      it 'does not check the self 65+ checkbox and sets line 7 to 0' do
        expect(instance.lines[:NJ1040_LINE_7_SELF].value).to eq(false)
        expect(instance.lines[:NJ1040_LINE_7_SPOUSE].value).to eq(false)
        expect(instance.lines[:NJ1040_LINE_7].value).to eq(0)
      end
    end
  end

  context 'when filing status is married filing jointly' do
    let(:intake) { create(:state_file_nj_intake, :married) }
    it "sets line 6 to 2000" do
      instance.calculate
      expect(instance.lines[:NJ1040_LINE_6].value).to eq(2000)
    end

    context 'when filer is older than 65 and spouse is older than 65' do
      let(:intake) { create(:state_file_nj_intake, :married_spouse_over_65, :primary_over_65) }
      before do
        instance.calculate
      end
      it 'checks both 65+ checkboxes and sets line 7 to 2000' do
        expect(instance.lines[:NJ1040_LINE_7_SELF].value).to eq(true)
        expect(instance.lines[:NJ1040_LINE_7_SPOUSE].value).to eq(true)
        expect(instance.lines[:NJ1040_LINE_7].value).to eq(2000)
      end
    end

    context 'when filer is younger than 65 and spouse is older than 65' do
      let(:intake) { create(:state_file_nj_intake, :married_spouse_over_65) }
      before do
        instance.calculate
      end
      it 'only checks the spouse 65+ checkbox and sets line 7 to 1000' do
        expect(instance.lines[:NJ1040_LINE_7_SELF].value).to eq(false)
        expect(instance.lines[:NJ1040_LINE_7_SPOUSE].value).to eq(true)
        expect(instance.lines[:NJ1040_LINE_7].value).to eq(1000)
      end
    end

    context 'when filer is older than 65 and spouse is younger than 65' do
      let(:intake) { create(:state_file_nj_intake, :married, :primary_over_65) }
      before do
        instance.calculate
      end
      it 'only checks the self 65+ checkbox and sets line 7 to 1000' do
        expect(instance.lines[:NJ1040_LINE_7_SELF].value).to eq(true)
        expect(instance.lines[:NJ1040_LINE_7_SPOUSE].value).to eq(false)
        expect(instance.lines[:NJ1040_LINE_7].value).to eq(1000)
      end
    end

    context 'when filer is younger than 65 and spouse is younger than 65' do
      let(:intake) { create(:state_file_nj_intake, :married) }
      before do
        instance.calculate
      end
      it 'checks neither checkbox and sets line 7 to 0' do
        expect(instance.lines[:NJ1040_LINE_7_SELF].value).to eq(false)
        expect(instance.lines[:NJ1040_LINE_7_SPOUSE].value).to eq(false)
        expect(instance.lines[:NJ1040_LINE_7].value).to eq(0)
      end
    end
  end
end
