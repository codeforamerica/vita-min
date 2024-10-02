require 'rails_helper'

def over_65_birth_year
  MultiTenantService.statefile.current_tax_year - 65
end

describe Efile::Nj::Nj1040 do
  let(:intake) { create(:state_file_nj_intake) }
  let(:instance) do
    described_class.new(
      year: MultiTenantService.statefile.current_tax_year,
      intake: intake
    )
  end
  before do
    instance.calculate
  end

  describe 'line 6 exemptions' do
    context 'when filing status is single' do
      let(:intake) { create(:state_file_nj_intake) }
      it "sets line 6 to 1000" do
        expect(instance.lines[:NJ1040_LINE_6].value).to eq(1000)
      end
    end

    context 'when filing status is married filing jointly' do
      let(:intake) { create(:state_file_nj_intake, :married_filing_jointly) }
      it "sets line 6 to 2000" do
        expect(instance.lines[:NJ1040_LINE_6].value).to eq(2000)
      end
    end
  end
  
  describe 'line 7 exemptions' do
    context 'when filer is older than 65 and spouse is older than 65' do
      let(:intake) { create(:state_file_nj_intake, :mfj_spouse_over_65, :primary_over_65) }

      it 'checks both 65+ checkboxes and sets line 7 to 2000' do
        expect(instance.lines[:NJ1040_LINE_7_SELF].value).to eq(true)
        expect(instance.lines[:NJ1040_LINE_7_SPOUSE].value).to eq(true)
        expect(instance.lines[:NJ1040_LINE_7].value).to eq(2000)
      end
    end

    context 'when filer is younger than 65 and spouse is older than 65' do
      let(:intake) { create(:state_file_nj_intake, :mfj_spouse_over_65) }

      it 'only checks the spouse 65+ checkbox and sets line 7 to 1000' do
        expect(instance.lines[:NJ1040_LINE_7_SELF].value).to eq(false)
        expect(instance.lines[:NJ1040_LINE_7_SPOUSE].value).to eq(true)
        expect(instance.lines[:NJ1040_LINE_7].value).to eq(1000)
      end
    end

    context 'when filer is older than 65 and spouse is younger than 65' do
      let(:intake) { create(:state_file_nj_intake, :married_filing_jointly, :primary_over_65) }

      it 'only checks the self 65+ checkbox and sets line 7 to 1000' do
        expect(instance.lines[:NJ1040_LINE_7_SELF].value).to eq(true)
        expect(instance.lines[:NJ1040_LINE_7_SPOUSE].value).to eq(false)
        expect(instance.lines[:NJ1040_LINE_7].value).to eq(1000)
      end
    end

    context 'when filer is younger than 65 and spouse is younger than 65' do
      let(:intake) { create(:state_file_nj_intake, :married_filing_jointly) }

      it 'checks neither checkbox and sets line 7 to 0' do
        expect(instance.lines[:NJ1040_LINE_7_SELF].value).to eq(false)
        expect(instance.lines[:NJ1040_LINE_7_SPOUSE].value).to eq(false)
        expect(instance.lines[:NJ1040_LINE_7].value).to eq(0)
      end
    end
  end

  describe 'line 8 exemptions' do
    context 'when filer is not blind and spouse is not blind' do
      let(:intake) { create(:state_file_nj_intake, :married_filing_jointly) }
      it 'sets line 8 deductions to 0' do
        expect(instance.lines[:NJ1040_LINE_8].value).to eq(0)
      end
    end

    context 'when filer is blind and spouse is not blind' do
      let(:intake) { create(:state_file_nj_intake, :primary_blind) }
      it 'sets line 8 deductions to 1000' do
        expect(instance.lines[:NJ1040_LINE_8].value).to eq(1000)
      end
    end

    context 'when filer is not blind and spouse is blind' do
      let(:intake) { create(:state_file_nj_intake, :spouse_blind) }
      it 'sets line 8 deductions to 1000' do
        expect(instance.lines[:NJ1040_LINE_8].value).to eq(1000)
      end
    end

    context 'when filer is blind and spouse is blind' do
      let(:intake) { create(:state_file_nj_intake, :primary_blind, :spouse_blind) }
      it 'sets line 8 deductions to 2000' do
        expect(instance.lines[:NJ1040_LINE_8].value).to eq(2000)
      end
    end
  end

  describe 'line 13 - total exemptions' do
    let(:intake) { create(:state_file_nj_intake, :primary_over_65, :primary_blind) }
    it 'sets line 13 to the sum of lines 6-8' do
      self_exemption = 1_000
      expect(instance.lines[:NJ1040_LINE_6].value).to eq(self_exemption)
      self_over_65 = 1_000
      expect(instance.lines[:NJ1040_LINE_7].value).to eq(self_over_65)
      self_blind = 1_000
      expect(instance.lines[:NJ1040_LINE_8].value).to eq(self_blind)
      expect(instance.lines[:NJ1040_LINE_13].value).to eq(self_exemption + self_over_65 + self_blind)
    end
  end

  describe 'line 15 - state wages' do
    context 'when no federal w2s' do
      let(:intake) { create(:state_file_nj_intake, :df_data_minimal) }

      it 'sets line 15 to -1 to indicate the sum does not exist' do
        expect(instance.lines[:NJ1040_LINE_15].value).to eq(-1)
      end
    end

    context 'when 2 federal w2s' do
      let(:intake) { create(:state_file_nj_intake, :df_data_2_w2s) }

      it 'sets line 15 to the rounded sum of all state wage amounts' do
        expected_sum = (12345.67 + 50000).round
        expect(instance.lines[:NJ1040_LINE_15].value).to eq(expected_sum)
      end
    end

    context 'when many federal w2s' do
      let(:intake) { create(:state_file_nj_intake, :df_data_many_w2s) }

      it 'sets line 15 to the rounded sum of all state wage amounts' do
        expected_sum = (50000.33 + 50000.33 + 50000.33 + 50000.33).round
        expect(instance.lines[:NJ1040_LINE_15].value).to eq(expected_sum)
      end
    end
  end

  describe 'line 27 - total income' do
    let(:intake) { create(:state_file_nj_intake, :df_data_2_w2s) }
    it 'sets line 27 to the rounded sum of all state wage amounts' do
      line_15_w2_wages = (12345.67 + 50000).round
      expect(instance.lines[:NJ1040_LINE_15].value).to eq(line_15_w2_wages)
      expect(instance.lines[:NJ1040_LINE_27].value).to eq(line_15_w2_wages)
    end
  end

  describe 'line 29 - gross income' do
    let(:intake) { create(:state_file_nj_intake, :df_data_2_w2s) }
    it 'sets line 29 to the rounded sum of all state wage amounts' do
      line_15_w2_wages = (12345.67 + 50000).round
      expect(instance.lines[:NJ1040_LINE_15].value).to eq(line_15_w2_wages)
      expect(instance.lines[:NJ1040_LINE_29].value).to eq(line_15_w2_wages)
    end
  end

  describe 'line 38 - total exemptions/deductions' do
    let(:intake) { create(:state_file_nj_intake, :primary_over_65, :primary_blind) }
    it 'sets line 38 to the total exemption amount' do
      self_exemption = 1_000
      self_over_65 = 1_000
      self_blind = 1_000
      total_exemptions = self_exemption + self_over_65 + self_blind
      expect(instance.lines[:NJ1040_LINE_38].value).to eq(total_exemptions)
    end
  end

  describe 'line 39 - taxable income' do
    let(:intake) { create(:state_file_nj_intake, :df_data_2_w2s, :primary_over_65, :primary_blind) }
    it 'sets line 39 to line 29 gross income minus line 38 total exemptions/deductions' do
      expected_total = instance.lines[:NJ1040_LINE_29].value - instance.lines[:NJ1040_LINE_38].value
      expect(instance.lines[:NJ1040_LINE_39].value).to eq(expected_total)
    end
  end

  describe 'line 40a - total property taxes paid' do
    context 'when homeowner' do
      context 'when married filing separately' do
        let(:intake) { 
          create(
            :state_file_nj_intake,
            :married_filing_separately,
            household_rent_own: 'own',
            property_tax_paid: 12345
          )
        }

        it 'sets line 40a to property_tax_paid divided by 2, rounded' do
          expect(instance.lines[:NJ1040_LINE_40A].value).to eq(6173)
        end
      end

      context 'when filing status is not MFS' do
        let(:intake) { 
          create(
            :state_file_nj_intake,
            household_rent_own: 'own',
            property_tax_paid: 12345
          )
        }

        it 'sets line 40a to property_tax_paid' do
          expect(instance.lines[:NJ1040_LINE_40A].value).to eq(12345)
        end
      end
    end

    context 'when renter' do
      context 'when married filing separately' do
        let(:intake) { 
          create(
            :state_file_nj_intake,
            :married_filing_separately,
            household_rent_own: 'rent',
            rent_paid: 12345
          )
        }

        it 'sets line 40a to 0.18 * rent_paid, then divided by 2, then rounded' do
          expect(instance.lines[:NJ1040_LINE_40A].value).to eq(1111)
        end
      end

      context 'when filing status is not MFS' do
        let(:intake) { 
          create(
            :state_file_nj_intake,
            household_rent_own: 'rent',
            rent_paid: 54321
          )
        }

        it 'sets line 40a to 0.18 * rent_paid, rounded' do
          expect(instance.lines[:NJ1040_LINE_40A].value).to eq(9778)
        end
      end
    end

    context 'when neither homeowner nor renter' do
      let(:intake) {
        create(
          :state_file_nj_intake,
          household_rent_own: 'neither',
        )
      }

      it 'sets line 40a to nil' do
        expect(instance.lines[:NJ1040_LINE_40A].value).to eq(nil)
      end
    end
  end

  describe 'line 42 - new jersey taxable income' do
    let(:intake) { create(:state_file_nj_intake, :df_data_2_w2s, :primary_over_65, :primary_blind) }
    it 'sets line 42 to line 39 (taxable income)' do
      expect(instance.lines[:NJ1040_LINE_42].value).to eq(instance.lines[:NJ1040_LINE_39].value)
    end
  end
end
