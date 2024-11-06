require 'rails_helper'

def over_65_birth_year
  MultiTenantService.statefile.current_tax_year - 65
end

describe Efile::Nj::Nj1040Calculator do
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

  describe 'get_tax_rate_and_subtraction_amount' do
    context 'when filing status is single' do
      let(:intake) { create(:state_file_nj_intake) }
      it "when income > 0 and <= 20,000, tax rate is .014 and subtraction is 0" do
        expect(instance.get_tax_rate_and_subtraction_amount(0)).to eq([0, 0])
        expect(instance.get_tax_rate_and_subtraction_amount(1)).to eq([0.014, 0])
        expect(instance.get_tax_rate_and_subtraction_amount(19_999)).to eq([0.014, 0])
        expect(instance.get_tax_rate_and_subtraction_amount(20_000)).to eq([0.014, 0])
      end

      it "when income > 20,000 and <= 35,000, tax rate is .0175 and subtraction is 70.00" do
        expect(instance.get_tax_rate_and_subtraction_amount(20_001)).to eq([0.0175, 70.00])
        expect(instance.get_tax_rate_and_subtraction_amount(34_999)).to eq([0.0175, 70.00])
        expect(instance.get_tax_rate_and_subtraction_amount(35_000)).to eq([0.0175, 70.00])
      end

      it "when income > 35,000 and <= 40,000, tax rate is .035 and subtraction is 682.50" do
        expect(instance.get_tax_rate_and_subtraction_amount(35_001)).to eq([0.035, 682.50])
        expect(instance.get_tax_rate_and_subtraction_amount(39_999)).to eq([0.035, 682.50])
        expect(instance.get_tax_rate_and_subtraction_amount(40_000)).to eq([0.035, 682.50])
      end

      it "when income > 40,000 and <= 75,000, tax rate is .05525 and subtraction is 1,492.50" do
        expect(instance.get_tax_rate_and_subtraction_amount(40_001)).to eq([0.05525, 1_492.50])
        expect(instance.get_tax_rate_and_subtraction_amount(74_999)).to eq([0.05525, 1_492.50])
        expect(instance.get_tax_rate_and_subtraction_amount(75_000)).to eq([0.05525, 1_492.50])
      end

      it "when income > 75,000 and <= 500,000, tax rate is .0637 and subtraction is 2,126.25" do
        expect(instance.get_tax_rate_and_subtraction_amount(75_001)).to eq([0.0637, 2_126.25])
        expect(instance.get_tax_rate_and_subtraction_amount(499_999)).to eq([0.0637, 2_126.25])
        expect(instance.get_tax_rate_and_subtraction_amount(500_000)).to eq([0.0637, 2_126.25])
      end

      it "when income > 500,000 and <= 1,000,000, tax rate is .0897 and subtraction is 15,126.25" do
        expect(instance.get_tax_rate_and_subtraction_amount(500_001)).to eq([0.0897, 15_126.25])
        expect(instance.get_tax_rate_and_subtraction_amount(999_999)).to eq([0.0897, 15_126.25])
        expect(instance.get_tax_rate_and_subtraction_amount(1_000_000)).to eq([0.0897, 15_126.25])
      end

      it "when income > 1,000,000, tax rate is .1075 and subtraction is 32,926.25" do
        expect(instance.get_tax_rate_and_subtraction_amount(1_000_001)).to eq([0.1075, 32_926.25])
        expect(instance.get_tax_rate_and_subtraction_amount(5_000_000)).to eq([0.1075, 32_926.25])
        expect(instance.get_tax_rate_and_subtraction_amount(100_000_000)).to eq([0.1075, 32_926.25])
      end
    end

    context 'when filing status is MFS' do
      let(:intake) { create(:state_file_nj_intake, :married_filing_separately) }
      it "returns same tax rates as single" do
        expect(instance.get_tax_rate_and_subtraction_amount(0)).to eq([0, 0])
        expect(instance.get_tax_rate_and_subtraction_amount(20_000)).to eq([0.014, 0])
        expect(instance.get_tax_rate_and_subtraction_amount(20_001)).to eq([0.0175, 70.00])
        expect(instance.get_tax_rate_and_subtraction_amount(35_000)).to eq([0.0175, 70.00])
        expect(instance.get_tax_rate_and_subtraction_amount(35_001)).to eq([0.035, 682.50])
        expect(instance.get_tax_rate_and_subtraction_amount(40_000)).to eq([0.035, 682.50])
        expect(instance.get_tax_rate_and_subtraction_amount(40_001)).to eq([0.05525, 1_492.50])
        expect(instance.get_tax_rate_and_subtraction_amount(75_000)).to eq([0.05525, 1_492.50])
        expect(instance.get_tax_rate_and_subtraction_amount(75_001)).to eq([0.0637, 2_126.25])
        expect(instance.get_tax_rate_and_subtraction_amount(500_000)).to eq([0.0637, 2_126.25])
        expect(instance.get_tax_rate_and_subtraction_amount(500_001)).to eq([0.0897, 15_126.25])
        expect(instance.get_tax_rate_and_subtraction_amount(1_000_000)).to eq([0.0897, 15_126.25])
        expect(instance.get_tax_rate_and_subtraction_amount(1_000_001)).to eq([0.1075, 32_926.25])
      end
    end

    context 'when filing status is married filing jointly' do
      let(:intake) { create(:state_file_nj_intake, :married_filing_jointly) }
      it "when income > 0 and <= 20,000, tax rate is .014, subtraction is 0" do
        expect(instance.get_tax_rate_and_subtraction_amount(0)).to eq([0, 0])
        expect(instance.get_tax_rate_and_subtraction_amount(1)).to eq([0.014, 0])
        expect(instance.get_tax_rate_and_subtraction_amount(19_999)).to eq([0.014, 0])
        expect(instance.get_tax_rate_and_subtraction_amount(20_000)).to eq([0.014, 0])
      end

      it "when income > 20,000 and <= 50,000, tax rate is .0175, subtraction is 70.00" do
        expect(instance.get_tax_rate_and_subtraction_amount(20_001)).to eq([0.0175, 70.00])
        expect(instance.get_tax_rate_and_subtraction_amount(49_999)).to eq([0.0175, 70.00])
        expect(instance.get_tax_rate_and_subtraction_amount(50_000)).to eq([0.0175, 70.00])
      end

      it "when income > 50,000 and <= 70,000, tax rate is .0245, subtraction is 420.00" do
        expect(instance.get_tax_rate_and_subtraction_amount(50_001)).to eq([0.0245, 420.00])
        expect(instance.get_tax_rate_and_subtraction_amount(69_999)).to eq([0.0245, 420.00])
        expect(instance.get_tax_rate_and_subtraction_amount(70_000)).to eq([0.0245, 420.00])
      end

      it "when income > 70,000 and <= 80,000, tax rate is .035, subtraction is 1,154.50" do
        expect(instance.get_tax_rate_and_subtraction_amount(70_001)).to eq([0.035, 1_154.50])
        expect(instance.get_tax_rate_and_subtraction_amount(79_999)).to eq([0.035, 1_154.50])
        expect(instance.get_tax_rate_and_subtraction_amount(80_000)).to eq([0.035, 1_154.50])
      end

      it "when income > 80,000 and <= 150,000, tax rate is .05525, subtraction is 2,775.00" do
        expect(instance.get_tax_rate_and_subtraction_amount(80_001)).to eq([0.05525, 2_775.00])
        expect(instance.get_tax_rate_and_subtraction_amount(149_999)).to eq([0.05525, 2_775.00])
        expect(instance.get_tax_rate_and_subtraction_amount(150_000)).to eq([0.05525, 2_775.00])
      end

      it "when income > 150,000 and <= 500,000, tax rate is .0637, subtraction is 4,042.50" do
        expect(instance.get_tax_rate_and_subtraction_amount(150_001)).to eq([0.0637, 4_042.50])
        expect(instance.get_tax_rate_and_subtraction_amount(499_999)).to eq([0.0637, 4_042.50])
        expect(instance.get_tax_rate_and_subtraction_amount(500_000)).to eq([0.0637, 4_042.50])
      end

      it "when income > 500,000 and <= 1,000,000, tax rate is .0897, subtraction is 17,042.50" do
        expect(instance.get_tax_rate_and_subtraction_amount(500_001)).to eq([0.0897, 17_042.50])
        expect(instance.get_tax_rate_and_subtraction_amount(999_999)).to eq([0.0897, 17_042.50])
        expect(instance.get_tax_rate_and_subtraction_amount(1_000_000)).to eq([0.0897, 17_042.50])
      end

      it "when income > 1,000,000, tax rate is .1075, subtraction is 34,842.50" do
        expect(instance.get_tax_rate_and_subtraction_amount(1_000_001)).to eq([0.1075, 34_842.50])
        expect(instance.get_tax_rate_and_subtraction_amount(5_000_000)).to eq([0.1075, 34_842.50])
        expect(instance.get_tax_rate_and_subtraction_amount(100_000_000)).to eq([0.1075, 34_842.50])
      end
    end

    context 'when filing status is head of household' do
      let(:intake) { create(:state_file_nj_intake, :head_of_household) }
      it "returns same tax rates as MFJ" do
        expect(instance.get_tax_rate_and_subtraction_amount(0)).to eq([0, 0])
        expect(instance.get_tax_rate_and_subtraction_amount(20_000)).to eq([0.014, 0])
        expect(instance.get_tax_rate_and_subtraction_amount(20_001)).to eq([0.0175, 70.00])
        expect(instance.get_tax_rate_and_subtraction_amount(50_000)).to eq([0.0175, 70.00])
        expect(instance.get_tax_rate_and_subtraction_amount(50_001)).to eq([0.0245, 420.00])
        expect(instance.get_tax_rate_and_subtraction_amount(70_000)).to eq([0.0245, 420.00])
        expect(instance.get_tax_rate_and_subtraction_amount(70_001)).to eq([0.035, 1_154.50])
        expect(instance.get_tax_rate_and_subtraction_amount(80_000)).to eq([0.035, 1_154.50])
        expect(instance.get_tax_rate_and_subtraction_amount(80_001)).to eq([0.05525, 2_775.00])
        expect(instance.get_tax_rate_and_subtraction_amount(150_000)).to eq([0.05525, 2_775.00])
        expect(instance.get_tax_rate_and_subtraction_amount(150_001)).to eq([0.0637, 4_042.50])
        expect(instance.get_tax_rate_and_subtraction_amount(500_000)).to eq([0.0637, 4_042.50])
        expect(instance.get_tax_rate_and_subtraction_amount(500_001)).to eq([0.0897, 17_042.50])
        expect(instance.get_tax_rate_and_subtraction_amount(1_000_000)).to eq([0.0897, 17_042.50])
        expect(instance.get_tax_rate_and_subtraction_amount(1_000_001)).to eq([0.1075, 34_842.50])
      end
    end

    context 'when filing status is qualifying widower' do
      let(:intake) { create(:state_file_nj_intake, :qualifying_widow) }
      it "returns same tax rates as MFJ" do
        expect(instance.get_tax_rate_and_subtraction_amount(0)).to eq([0, 0])
        expect(instance.get_tax_rate_and_subtraction_amount(20_000)).to eq([0.014, 0])
        expect(instance.get_tax_rate_and_subtraction_amount(20_001)).to eq([0.0175, 70.00])
        expect(instance.get_tax_rate_and_subtraction_amount(50_000)).to eq([0.0175, 70.00])
        expect(instance.get_tax_rate_and_subtraction_amount(50_001)).to eq([0.0245, 420.00])
        expect(instance.get_tax_rate_and_subtraction_amount(70_000)).to eq([0.0245, 420.00])
        expect(instance.get_tax_rate_and_subtraction_amount(70_001)).to eq([0.035, 1_154.50])
        expect(instance.get_tax_rate_and_subtraction_amount(80_000)).to eq([0.035, 1_154.50])
        expect(instance.get_tax_rate_and_subtraction_amount(80_001)).to eq([0.05525, 2_775.00])
        expect(instance.get_tax_rate_and_subtraction_amount(150_000)).to eq([0.05525, 2_775.00])
        expect(instance.get_tax_rate_and_subtraction_amount(150_001)).to eq([0.0637, 4_042.50])
        expect(instance.get_tax_rate_and_subtraction_amount(500_000)).to eq([0.0637, 4_042.50])
        expect(instance.get_tax_rate_and_subtraction_amount(500_001)).to eq([0.0897, 17_042.50])
        expect(instance.get_tax_rate_and_subtraction_amount(1_000_000)).to eq([0.0897, 17_042.50])
        expect(instance.get_tax_rate_and_subtraction_amount(1_000_001)).to eq([0.1075, 34_842.50])
      end
    end
  end

  describe 'calculate_use_tax' do
    let(:intake) { create(:state_file_nj_intake) }
    it "when income <= 15,000, use tax is $14" do
      expect(instance.calculate_use_tax(-1000)).to eq(14)
      expect(instance.calculate_use_tax(-1)).to eq(14)
      expect(instance.calculate_use_tax(0)).to eq(14)
      expect(instance.calculate_use_tax(1)).to eq(14)
      expect(instance.calculate_use_tax(14_999)).to eq(14)
      expect(instance.calculate_use_tax(15_000)).to eq(14)
    end

    it "when income > 15,000 and <= 30,000, use tax is $44" do
      expect(instance.calculate_use_tax(15_001)).to eq(44)
      expect(instance.calculate_use_tax(29_999)).to eq(44)
      expect(instance.calculate_use_tax(30_000)).to eq(44)
    end

    it "when income > 30,000 and <= 50,000, use tax is $64" do
      expect(instance.calculate_use_tax(30_001)).to eq(64)
      expect(instance.calculate_use_tax(49_999)).to eq(64)
      expect(instance.calculate_use_tax(50_000)).to eq(64)
    end

    it "when income > 50,000 and <= 75,000, use tax is $84" do
      expect(instance.calculate_use_tax(50_001)).to eq(84)
      expect(instance.calculate_use_tax(74_999)).to eq(84)
      expect(instance.calculate_use_tax(75_000)).to eq(84)
    end

    it "when income > 75,000 and <= 100,000, use tax is $106" do
      expect(instance.calculate_use_tax(75_001)).to eq(106)
      expect(instance.calculate_use_tax(99_999)).to eq(106)
      expect(instance.calculate_use_tax(100_000)).to eq(106)
    end

    it "when income > 100,000 and <= 150,000, use tax is $134" do
      expect(instance.calculate_use_tax(100_001)).to eq(134)
      expect(instance.calculate_use_tax(149_999)).to eq(134)
      expect(instance.calculate_use_tax(150_000)).to eq(134)
    end

    it "when income > 150,000 and <= 200,000, use tax is $170" do
      expect(instance.calculate_use_tax(150_001)).to eq(170)
      expect(instance.calculate_use_tax(199_999)).to eq(170)
      expect(instance.calculate_use_tax(200_000)).to eq(170)
    end

    it "when income > 200,000, use tax is 0.0852% or $494, whichever is less, rounded" do
      expect(instance.calculate_use_tax(200_001)).to eq(170)
      expect(instance.calculate_use_tax(500_000)).to eq(426)
      expect(instance.calculate_use_tax(579_000)).to eq(493)
      expect(instance.calculate_use_tax(579_813)).to eq(494)
      expect(instance.calculate_use_tax(1_000_000)).to eq(494)
    end
  end

  describe 'line 6 exemptions' do
    context 'when filing status is single' do
      let(:intake) { create(:state_file_nj_intake) }
      it "sets line 6 to 1000" do
        expect(instance.calculate_line_6).to eq(1000)
      end
    end

    context 'when filing status is married filing jointly' do
      let(:intake) { create(:state_file_nj_intake, :married_filing_jointly) }
      it "sets line 6 to 2000" do
        expect(instance.calculate_line_6).to eq(2000)
      end
    end
  end
  
  describe 'line 7 exemptions' do
    context 'when filer is older than 65 and spouse is older than 65' do
      let(:intake) { create(:state_file_nj_intake, :mfj_spouse_over_65, :primary_over_65) }

      it 'checks both 65+ checkboxes and sets line 7 to 2000' do
        expect(instance.lines[:NJ1040_LINE_7_SELF].value).to eq(true)
        expect(instance.lines[:NJ1040_LINE_7_SPOUSE].value).to eq(true)
        expect(instance.calculate_line_7).to eq(2000)
      end
    end

    context 'when filer is younger than 65 and spouse is older than 65' do
      let(:intake) { create(:state_file_nj_intake, :mfj_spouse_over_65) }

      it 'only checks the spouse 65+ checkbox and sets line 7 to 1000' do
        expect(instance.lines[:NJ1040_LINE_7_SELF].value).to eq(false)
        expect(instance.lines[:NJ1040_LINE_7_SPOUSE].value).to eq(true)
        expect(instance.calculate_line_7).to eq(1000)
      end
    end

    context 'when filer is older than 65 and spouse is younger than 65' do
      let(:intake) { create(:state_file_nj_intake, :married_filing_jointly, :primary_over_65) }

      it 'only checks the self 65+ checkbox and sets line 7 to 1000' do
        expect(instance.lines[:NJ1040_LINE_7_SELF].value).to eq(true)
        expect(instance.lines[:NJ1040_LINE_7_SPOUSE].value).to eq(false)
        expect(instance.calculate_line_7).to eq(1000)
      end
    end

    context 'when filer is younger than 65 and spouse is younger than 65' do
      let(:intake) { create(:state_file_nj_intake, :married_filing_jointly) }

      it 'checks neither checkbox and sets line 7 to 0' do
        expect(instance.lines[:NJ1040_LINE_7_SELF].value).to eq(false)
        expect(instance.lines[:NJ1040_LINE_7_SPOUSE].value).to eq(false)
        expect(instance.calculate_line_7).to eq(0)
      end
    end
  end

  describe 'line 8 exemptions' do
    context 'when filer is not blind and spouse is not blind' do
      let(:intake) { create(:state_file_nj_intake, :married_filing_jointly) }
      it 'sets line 8 deductions to 0' do
        expect(instance.calculate_line_8).to eq(0)
      end
    end

    context 'when filer is blind and spouse is not blind' do
      let(:intake) { create(:state_file_nj_intake, :primary_blind) }
      it 'sets line 8 deductions to 1000' do
        expect(instance.calculate_line_8).to eq(1000)
      end
    end

    context 'when filer is not blind and spouse is blind' do
      let(:intake) { create(:state_file_nj_intake, :spouse_blind) }
      it 'sets line 8 deductions to 1000' do
        expect(instance.calculate_line_8).to eq(1000)
      end
    end

    context 'when filer is blind and spouse is blind' do
      let(:intake) { create(:state_file_nj_intake, :primary_blind, :spouse_blind) }
      it 'sets line 8 deductions to 2000' do
        expect(instance.calculate_line_8).to eq(2000)
      end
    end

    context 'when filer is disabled but not blind' do
      let(:intake) { create(:state_file_nj_intake, :primary_disabled)}
      it 'sets line 8 deductions to 1000' do
        expect(instance.calculate_line_8).to eq(1000)
      end
    end

    context 'when filer is disabled and blind' do
      let(:intake) { create(:state_file_nj_intake, :primary_disabled, :primary_blind)}
      it 'sets line 8 deductions to 1000' do
        expect(instance.calculate_line_8).to eq(1000)
      end
    end

    context 'when spouse is disabled' do
      let(:intake) { create(:state_file_nj_intake, :spouse_disabled)}
      it 'sets line 8 deductions to 1000' do
        expect(instance.calculate_line_8).to eq(1000)
      end
    end

    context 'when spouse and primary are disabled' do
      let(:intake) { create(:state_file_nj_intake, :spouse_disabled, :primary_disabled)}
      it 'sets line 8 deductions to 2000' do
        expect(instance.calculate_line_8).to eq(2000)
      end
    end
  end

  describe 'line 9 - veterans exemption' do
    context 'when filer is a veteran' do
      let(:intake) { create(:state_file_nj_intake, :primary_veteran) }
      it 'sets line 9 deductions to 6000' do
        expect(instance.calculate_line_9).to eq(6000)
      end
    end

    context 'when filer and their spouse are both veterans' do
      let(:intake) { create(:state_file_nj_intake, :primary_veteran, :spouse_veteran) }
      it 'sets line 9 deductions to 12000' do
        expect(instance.calculate_line_9).to eq(12000)
      end
    end
  end

  describe 'line 13 - total exemptions' do
    let(:intake) { create(:state_file_nj_intake, :primary_over_65, :primary_blind, :primary_veteran) }
    it 'sets line 13 to the sum of lines 6-9' do
      self_exemption = 1_000
      expect(instance.calculate_line_6).to eq(self_exemption)
      self_over_65 = 1_000
      expect(instance.calculate_line_7).to eq(self_over_65)
      self_blind = 1_000
      expect(instance.calculate_line_8).to eq(self_blind)
      self_veteran = 6_000
      expect(instance.calculate_line_9).to eq(self_veteran)
      expect(instance.lines[:NJ1040_LINE_13].value).to eq(self_exemption + self_over_65 + self_blind + self_veteran)
    end
  end

  describe 'line 15 - state wages' do
    let(:intake) { create(:state_file_nj_intake) }

    context 'when no state file w2s' do
      let(:intake) { create(:state_file_nj_intake, :df_data_minimal) }
      it 'sets line 15 to -1 to indicate the sum does not exist' do
        expect(instance.lines[:NJ1040_LINE_15].value).to eq(-1)
      end
    end

    context 'when 2 state file w2s' do
      let(:intake) { create(:state_file_nj_intake, :df_data_2_w2s) }
      it 'sets line 15 to the sum of all state wage amounts' do
        expected_sum = 12345 + 50000
        expect(instance.lines[:NJ1040_LINE_15].value).to eq(expected_sum)
      end
    end

    context 'when many state file w2s' do
      let(:intake) { create(:state_file_nj_intake, :df_data_many_w2s) }
      it 'sets line 15 to the sum of all state wage amounts' do
        expected_sum = 50000 + 50000 + 50000 + 50000
        expect(instance.lines[:NJ1040_LINE_15].value).to eq(expected_sum)
      end
    end
  end

  describe 'line 16a taxable interest income' do
    context 'with no interest reports' do
      let(:intake) { create(:state_file_nj_intake, :df_data_minimal) }
      it 'does not set line 16a' do
        expect(instance.lines[:NJ1040_LINE_16A].value).to eq(nil)
      end
    end

    context 'with interest reports, but no interest on government bonds' do
      let(:intake) { create(:state_file_nj_intake, :df_data_one_dep) }
      it 'does not set line 16a' do
        expect(instance.lines[:NJ1040_LINE_16A].value).to eq(nil)
      end
    end

    context 'with interest on government bonds' do
      let(:intake) { create(:state_file_nj_intake, :df_data_two_deps) }
      it 'sets line 16a to 300 (fed taxable interest 500 minus sum of bond interest 200)' do
        expect(instance.lines[:NJ1040_LINE_16A].value).to eq(300)
      end
    end
  end

  describe 'line 16b tax exempt interest income' do
    context 'with federal tax exempt interest income and interest on government bonds' do
      let(:intake) { create(:state_file_nj_intake, :df_data_exempt_interest) }
      it 'calculates the sum' do
        expect(instance.calculate_tax_exempt_interest_income).to eq(10_001)
      end
    end

    context 'with no tax exempt interest income' do
      let(:intake) { create(:state_file_nj_intake, :df_data_minimal) }
      it 'does not set line 16b' do
        expect(instance.lines[:NJ1040_LINE_16B].value).to eq(nil)
      end
    end

    context 'with tax exempt interest income and interest on government bonds less than 10k' do
      let(:intake) { create(:state_file_nj_intake, :df_data_two_deps) }
      it 'sets line 1b to the sum' do
        expect(instance.lines[:NJ1040_LINE_16B].value).to eq(201)
      end
    end
  end

  describe 'line 27 - total income' do
    let(:intake) { create(:state_file_nj_intake) }

    it 'sets line 27 to the sum of all state wage amounts' do
      allow(instance).to receive(:calculate_line_15).and_return 50000
      instance.calculate
      expect(instance.lines[:NJ1040_LINE_27].value).to eq(50000)
    end
  end

  describe 'line 29 - gross income' do
    let(:intake) { create(:state_file_nj_intake) }

    it 'sets line 29 to the sum of all state wage amounts' do
      allow(instance).to receive(:calculate_line_15).and_return 50000
      instance.calculate
      expect(instance.lines[:NJ1040_LINE_29].value).to eq(50000)
    end
  end

  describe 'line 31 - medical expenses' do
    let(:intake) { create(:state_file_nj_intake, medical_expenses: medical_expenses)}

    before do
      allow(instance).to receive(:calculate_line_29).and_return gross_income
      allow(instance).to receive(:calculate_line_13).and_return 1000
      instance.calculate
    end

    context 'when gross income is 0' do
      let(:gross_income) { 0 }
      let(:medical_expenses) { 1234 }

      it 'sets line 31 to the entire cost of medical expenses' do
        expect(instance.lines[:NJ1040_LINE_31].value).to eq(1234)
      end

      it 'includes medical expenses in line 38' do
        expect(instance.lines[:NJ1040_LINE_38].value).to eq(2234)
      end
    end

    context 'when medical expenses exceed 2% of gross income' do
      let(:gross_income) { 10_000 }
      let(:medical_expenses) { 201.11 }

      it 'sets line 31 to medical expenses minus $200, rounded' do
        expect(instance.lines[:NJ1040_LINE_31].value).to eq(1)
      end

      it 'includes medical expenses in line 38' do
        expect(instance.lines[:NJ1040_LINE_38].value).to eq(1001)
      end
    end

    context 'when medical expenses do not exceed 2% of gross income' do
      let(:gross_income) { 10_000 }
      let(:medical_expenses) { 199 }

      it 'does not set a value for line 31' do
        expect(instance.lines[:NJ1040_LINE_31].value).to eq(nil)
      end

      it 'does not alter line 38' do
        expect(instance.lines[:NJ1040_LINE_38].value).to eq(1000)
      end
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
      context 'when married filing separately living in the same home' do
        let(:intake) { 
          create(
            :state_file_nj_intake,
            :married_filing_separately,
            household_rent_own: 'own',
            property_tax_paid: 12345,
            homeowner_same_home_spouse: 'yes'
          )
        }

        it 'sets line 40a to property_tax_paid divided by 2, rounded' do
          expect(instance.lines[:NJ1040_LINE_40A].value).to eq(6173)
        end
      end

      context 'when married filing separately NOT living in the same home' do
        let(:intake) {
          create(
            :state_file_nj_intake,
            :married_filing_separately,
            household_rent_own: 'own',
            property_tax_paid: 12345.77,
            homeowner_same_home_spouse: 'no'
          )
        }

        it 'sets line 40a to property_tax_paid rounded' do
          expect(instance.lines[:NJ1040_LINE_40A].value).to eq(12346)
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

      context 'when property tax paid is nil (not eligible)' do
        let(:intake) {
          create(
            :state_file_nj_intake,
            household_rent_own: 'own',
            property_tax_paid: nil
          )
        }

        it 'sets line 40a to nil' do
          expect(instance.lines[:NJ1040_LINE_40A].value).to eq(nil)
        end
      end
    end

    context 'when renter' do
      context 'when married filing separately living in the same home' do
        let(:intake) { 
          create(
            :state_file_nj_intake,
            :married_filing_separately,
            household_rent_own: 'rent',
            tenant_same_home_spouse: 'yes',
            rent_paid: 12345
          )
        }

        it 'sets line 40a to 0.18 * rent_paid, then divided by 2, then rounded' do
          expect(instance.lines[:NJ1040_LINE_40A].value).to eq(1111)
        end
      end

      context 'when married filing separately NOT living in the same home' do
        let(:intake) {
          create(
            :state_file_nj_intake,
            :married_filing_separately,
            household_rent_own: 'rent',
            tenant_same_home_spouse: 'no',
            rent_paid: 12345
          )
        }

        it 'sets line 40a to 0.18 * rent_paid, rounded' do
          expect(instance.lines[:NJ1040_LINE_40A].value).to eq(2222)
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

  describe 'should_use_property_tax_deduction' do
    context "calculate_tax_liability_with_deduction is nil" do
      it "returns false" do
        allow(instance).to receive(:calculate_tax_liability_with_deduction).and_return nil
        expect(instance.should_use_property_tax_deduction).to eq false
      end
    end

    context "calculate_tax_liability_without_deduction - calculate_tax_liability_with_deduction is > 50" do
      it "returns true" do
        allow(instance).to receive(:calculate_tax_liability_without_deduction).and_return 100
        allow(instance).to receive(:calculate_tax_liability_with_deduction).and_return 49
        expect(instance.should_use_property_tax_deduction).to eq true
      end
    end

    context "calculate_tax_liability_without_deduction - calculate_tax_liability_with_deduction is = 50" do
      it "returns true" do
        allow(instance).to receive(:calculate_tax_liability_without_deduction).and_return 100
        allow(instance).to receive(:calculate_tax_liability_with_deduction).and_return 50
        expect(instance.should_use_property_tax_deduction).to eq true
      end
    end

    context "calculate_tax_liability_without_deduction - calculate_tax_liability_with_deduction is < 50" do
      it "returns false" do
        allow(instance).to receive(:calculate_tax_liability_without_deduction).and_return 100
        allow(instance).to receive(:calculate_tax_liability_with_deduction).and_return 51
        expect(instance.should_use_property_tax_deduction).to eq false
      end
    end
  end

  describe 'calculate_property_tax_deduction' do
    context 'when married filing separately, same home' do
      let(:intake) {
        create(
          :state_file_nj_intake,
          :married_filing_separately,
          tenant_same_home_spouse: 'yes',
        )
      }

      it 'when 40a > 7500, property tax deduction is 7500' do
        allow(instance).to receive(:calculate_line_40a).and_return 7501
        expect(instance.calculate_property_tax_deduction).to eq(7500)
      end

      it 'when 40a = 7500, property tax deduction is line 40a' do
        allow(instance).to receive(:calculate_line_40a).and_return 7500
        expect(instance.calculate_property_tax_deduction).to eq(7500)
      end

      it 'when 40a < 7500, property tax deduction is line 40a' do
        allow(instance).to receive(:calculate_line_40a).and_return 7499
        expect(instance.calculate_property_tax_deduction).to eq(7499)
      end
    end

    context 'when married filing separately, same home - homeowner' do
      let(:intake) {
        create(
          :state_file_nj_intake,
          :married_filing_separately,
          homeowner_same_home_spouse: 'yes',
          )
      }

      it 'when 40a > 7500, property tax deduction is 7500' do
        allow(instance).to receive(:calculate_line_40a).and_return 7501
        expect(instance.calculate_property_tax_deduction).to eq(7500)
      end
    end

    context 'when married filing separately, not same home' do
      let(:intake) {
        create(
          :state_file_nj_intake,
          :married_filing_separately,
          tenant_same_home_spouse: 'no',
          )
      }

      it 'when 40a > 15000, property tax deduction is 15000' do
        allow(instance).to receive(:calculate_line_40a).and_return 15_001
        expect(instance.calculate_property_tax_deduction).to eq(15_000)
      end

      it 'when 40a = 15000, property tax deduction is line 40a' do
        allow(instance).to receive(:calculate_line_40a).and_return 15_000
        expect(instance.calculate_property_tax_deduction).to eq(15_000)
      end

      it 'when 40a < 15000, property tax deduction is line 40a' do
        allow(instance).to receive(:calculate_line_40a).and_return 14_999
        expect(instance.calculate_property_tax_deduction).to eq(14_999)
      end
    end

    context 'when any status other than MFS' do
      let(:intake) {
        create(
          :state_file_nj_intake,
          :married_filing_jointly
          )
      }

      it 'when 40a > 15000, property tax deduction is 15000' do
        allow(instance).to receive(:calculate_line_40a).and_return 15_001
        instance.calculate
        expect(instance.calculate_property_tax_deduction).to eq(15_000)
      end

      it 'when 40a = 15000, property tax deduction is line 40a' do
        allow(instance).to receive(:calculate_line_40a).and_return 15_000
        instance.calculate
        expect(instance.calculate_property_tax_deduction).to eq(15_000)
      end

      it 'when 40a < 15000, property tax deduction is line 40a' do
        allow(instance).to receive(:calculate_line_40a).and_return 14_999
        instance.calculate
        expect(instance.calculate_property_tax_deduction).to eq(14_999)
      end
    end
  end

  describe "calculate_line_41" do
    context "when should_use_property_tax_deduction is true" do
      it "returns calculate_property_tax_deduction" do
        allow(instance).to receive(:should_use_property_tax_deduction).and_return true
        allow(instance).to receive(:calculate_property_tax_deduction).and_return 15_000
        instance.calculate
        expect(instance.lines[:NJ1040_LINE_41].value).to eq(15_000)
      end
    end

    context "when should_use_property_tax_deduction is false" do
      it "returns nil" do
        allow(instance).to receive(:should_use_property_tax_deduction).and_return false
        instance.calculate
        expect(instance.lines[:NJ1040_LINE_41].value).to be_nil
      end
    end
  end

  describe 'calculate_tax_liability_with_deduction' do
    let(:intake) {
      create(:state_file_nj_intake)
    }
    it 'subtracts property_tax_deduction from line 39 times tax rate' do
      allow(instance).to receive(:calculate_line_39).and_return 36_000
      allow(instance).to receive(:calculate_property_tax_deduction).and_return 2_000
      expected = 525 # 34,000 * 0.0175 - 70
      expect(instance.calculate_tax_liability_with_deduction).to eq(expected)
    end
  end

  describe 'calculate_tax_liability_without_deduction' do
    let(:intake) {
      create(:state_file_nj_intake)
    }
    it 'returns line 39 times tax rate' do
      allow(instance).to receive(:calculate_line_39).and_return 36_000
      expected = 577.50 # 36,000 * 0.035 - 682.50
      expect(instance.calculate_tax_liability_without_deduction).to eq(expected)
    end
  end

  describe 'lines 41, 42, 43, 56 - property tax deduction' do
    context 'when without_deduction - with_deduction >= $50' do
      let(:intake) {
        create(:state_file_nj_intake)
      }
      before do
        allow(instance).to receive(:is_ineligible_or_unsupported_for_property_tax).and_return false
        allow(instance).to receive(:calculate_property_tax_deduction).and_return 2_000
        allow(instance).to receive(:calculate_line_39).and_return 20_000
        allow(instance).to receive(:calculate_tax_liability_with_deduction).and_return 10_000.77
        allow(instance).to receive(:calculate_tax_liability_without_deduction).and_return 10_050.77
        instance.calculate
      end

      it 'sets line 41 to property_tax_deduction' do
        expect(instance.lines[:NJ1040_LINE_41].value).to eq(2_000)
      end

      it 'sets line 42 to line 39 minus property_tax_deduction' do
        expect(instance.lines[:NJ1040_LINE_42].value).to eq(18_000)
      end

      it 'sets line 43 to with_deduction rounded' do
        expect(instance.lines[:NJ1040_LINE_43].value).to eq(10_001)
      end

      it 'sets line 56 to nil' do
        expect(instance.lines[:NJ1040_LINE_56].value).to eq(nil)
      end
    end

    context 'when without_deduction - with_deduction < $50' do
      let(:intake) {
        create(:state_file_nj_intake)
      }
      before do
        allow(instance).to receive(:is_ineligible_or_unsupported_for_property_tax).and_return false
        allow(instance).to receive(:calculate_property_tax_deduction).and_return 2_000
        allow(instance).to receive(:calculate_line_39).and_return 20_000
        allow(instance).to receive(:calculate_tax_liability_with_deduction).and_return 10_000.21
        allow(instance).to receive(:calculate_tax_liability_without_deduction).and_return 10_049.21
        instance.calculate
      end

      it 'sets line 41 to nil' do
        expect(instance.lines[:NJ1040_LINE_41].value).to eq(nil)
      end

      it 'sets line 42 to line 39' do
        expect(instance.lines[:NJ1040_LINE_42].value).to eq(20_000)
      end

      it 'sets line 43 to without_deduction, rounded' do
        expect(instance.lines[:NJ1040_LINE_43].value).to eq(10_049)
      end

      context 'when MFS living in same home - tenant' do
        let(:intake) {
          create(
            :state_file_nj_intake,
            :married_filing_separately,
            tenant_same_home_spouse: 'yes',
            )
        }

        it 'sets line 56 to $25' do
          expect(instance.lines[:NJ1040_LINE_56].value).to eq(25)
        end
      end

      context 'when MFS living in same home - homeowner' do
        let(:intake) {
          create(
            :state_file_nj_intake,
            :married_filing_separately,
            homeowner_same_home_spouse: 'yes',
            )
        }

        it 'sets line 56 to $25' do
          expect(instance.lines[:NJ1040_LINE_56].value).to eq(25)
        end
      end

      context 'when not MFS or MFS in separate home - tenant' do
        let(:intake) {
          create(
            :state_file_nj_intake,
            :married_filing_separately,
            tenant_same_home_spouse: 'no',
            )
        }

        it 'sets line 56 to $50' do
          expect(instance.lines[:NJ1040_LINE_56].value).to eq(50)
        end
      end

      context 'when not MFS or MFS in separate home - homeowner' do
        let(:intake) {
          create(
            :state_file_nj_intake,
            :married_filing_separately,
            homeowner_same_home_spouse: 'no',
            )
        }

        it 'sets line 56 to $50' do
          expect(instance.lines[:NJ1040_LINE_56].value).to eq(50)
        end
      end
    end

    context 'when ineligible for property tax' do
      let(:intake) {
        create(:state_file_nj_intake)
      }
      before do
        allow(instance).to receive(:is_ineligible_or_unsupported_for_property_tax).and_return true
        allow(instance).to receive(:calculate_line_39).and_return 20_000
        allow(instance).to receive(:calculate_tax_liability_without_deduction).and_return 10_000
        instance.calculate
      end

      it 'sets line 41 to nil' do
        expect(instance.lines[:NJ1040_LINE_41].value).to eq(nil)
      end

      it 'sets line 42 to line 39' do
        expect(instance.lines[:NJ1040_LINE_42].value).to eq(20_000)
      end

      it 'sets line 43 to tax liability without deduction' do
        expect(instance.lines[:NJ1040_LINE_43].value).to eq(10_000)
      end

      it 'sets line 56 to nil' do
        expect(instance.lines[:NJ1040_LINE_56].value).to eq(nil)
      end
    end
  end

  describe 'line 42 - new jersey taxable income' do
    let(:intake) { create(:state_file_nj_intake, :primary_over_65, :primary_blind) }
    it 'sets line 42 to line 39 (taxable income)' do
      expect(instance.lines[:NJ1040_LINE_42].value).to eq(instance.lines[:NJ1040_LINE_39].value)
    end
  end

  describe 'line 51 - sales and use tax' do
    
    context 'when sales_use_tax exists (already calculated automated or manual)' do
      let(:intake) { create(:state_file_nj_intake, sales_use_tax: 400.77 )}
      it 'sets line 51 to the rounded sales_use_tax' do
        expect(instance.lines[:NJ1040_LINE_51].value).to eq 401
      end
    end

    context 'when sales_use_tax is nil' do
      let(:intake) { create(:state_file_nj_intake, sales_use_tax: nil)}
      it 'sets line 51 to 0' do
        expect(instance.lines[:NJ1040_LINE_51].value).to eq 0
      end
    end
  end

  describe 'line 58 - earned income tax credit' do
    context 'when there is EarnedIncomeCreditAmt on the federal 1040' do
      let(:intake) { create(:state_file_nj_intake) }

      it 'sets line 58 to 40% of federal EITC (40% of $1490) and checks IRS box' do
        expect(instance.lines[:NJ1040_LINE_58].value).to eq(596)
        expect(instance.lines[:NJ1040_LINE_58_IRS].value).to eq(true)
      end
    end

    context 'when there is no EarnedIncomeCreditAmt on the federal 1040' do
      context 'when taxpayer satisfies all eligibility checks' do
        context 'when taxpayer is a qualifying child' do
          let(:intake) { create(:state_file_nj_intake, :df_data_minimal) } # TODO

          it 'sets line 58 to 0' do
            expect(instance.lines[:NJ1040_LINE_58].value).to eq(0)
            expect(instance.lines[:NJ1040_LINE_58_IRS].value).to eq(false)
          end
        end

        context 'when spouse is a qualifying child' do
          let(:intake) { create(:state_file_nj_intake, :df_data_minimal) } # TODO

          it 'sets line 58 to 0' do
            expect(instance.lines[:NJ1040_LINE_58].value).to eq(0)
            expect(instance.lines[:NJ1040_LINE_58_IRS].value).to eq(false)
          end
        end

        context 'when neither taxpayer nor spouse is a qualifying child' do
          # let(:intake) { create(:state_file_nj_intake, :df_data_minimal) }

          it 'sets line 58 to flat $240 and does not check IRS box' do
            expect(instance.lines[:NJ1040_LINE_58].value).to eq(240)
            expect(instance.lines[:NJ1040_LINE_58_IRS].value).to eq(false)
          end
        end
      end

      context 'when taxpayer does not satisfy one or more eligibility checks' do
        let(:intake) { create(:state_file_nj_intake, :df_data_minimal) }

        it 'sets line 58 to 0' do
          expect(instance.lines[:NJ1040_LINE_58].value).to eq(0)
          expect(instance.lines[:NJ1040_LINE_58_IRS].value).to eq(false)
        end
      end
    end
  end

  describe 'line 64 - child and dependent care credit' do
    let(:intake) { 
      create(
      :state_file_nj_intake,
      :df_data_one_dep,
      :fed_credit_for_child_and_dependent_care)
    }
    
    context 'with an income of over 150k' do
      it 'returns nil' do
        allow(instance).to receive(:calculate_line_42).and_return 150_001
        instance.calculate
        expect(instance.lines[:NJ1040_LINE_64].value).to eq(nil)
      end
    end

    context 'with an income of 150k or less' do
      before do
        allow(instance).to receive(:calculate_line_42).and_return nj_taxable_income
        instance.calculate
      end

      context "with an income of 150k or less" do
        let(:nj_taxable_income) { 150_000 }
        it 'returns 10% of federal credit' do
          expect(instance.lines[:NJ1040_LINE_64].value).to eq(100)
        end
      end

      context "with an income of 120k or less" do
        let(:nj_taxable_income) { 120_000 }
        it 'returns 20% of federal credit' do
          expect(instance.lines[:NJ1040_LINE_64].value).to eq(200)
        end
      end

      context "with an income of 90k or less" do
        let(:nj_taxable_income) { 90_000 }
        it 'returns 30% of federal credit' do
          expect(instance.lines[:NJ1040_LINE_64].value).to eq(300)
        end
      end

      context "with an income of 60k or less" do
        let(:nj_taxable_income) { 60_000 }
        it 'returns 40% of federal credit' do
          expect(instance.lines[:NJ1040_LINE_64].value).to eq(400)
        end
      end

      context "with an income of 30k or less" do
        let(:nj_taxable_income) { 30_000 }
        it 'returns 50% of federal credit' do
          expect(instance.lines[:NJ1040_LINE_64].value).to eq(500)
        end
      end
    end
  end

  describe 'line 65 - NJ child tax credit' do
    context 'when taxpayer is married filing separately' do
      let(:intake) { create(:state_file_nj_intake, :married_filing_separately) }
      it 'returns nil' do
        instance.calculate
        expect(instance.lines[:NJ1040_LINE_65].value).to eq(nil)
      end
    end

    context 'when taxable income is over 80k' do
      let(:intake) { create(:state_file_nj_intake, :df_data_one_dep) }
      it 'returns nil' do
        allow(instance).to receive(:number_of_dependents_age_5_younger).and_return 10
        allow(instance).to receive(:calculate_line_42).and_return 80_001
        instance.calculate
        expect(instance.lines[:NJ1040_LINE_65].value).to eq(nil)
      end
    end

    context 'when taxable income is under 80k and taxpayer has 1 dependent' do
      let(:intake) { create(:state_file_nj_intake, :df_data_one_dep) }

      before do
        allow(instance).to receive(:number_of_dependents_age_5_younger).and_return 1
        allow(instance).to receive(:calculate_line_42).and_return nj_taxable_income
        instance.calculate
      end

      context "for incomes of 30k or less" do
        let(:nj_taxable_income) { 30_000 }
        it 'returns 1000' do
          expect(instance.lines[:NJ1040_LINE_65].value).to eq(1000)
        end
      end

      context "for incomes of 40k or less" do
        let(:nj_taxable_income) { 40_000 }
        it 'returns 800' do
          expect(instance.lines[:NJ1040_LINE_65].value).to eq(800)
        end
      end

      context "for incomes of 50k or less" do
        let(:nj_taxable_income) { 50_000 }
        it 'returns 600' do
          expect(instance.lines[:NJ1040_LINE_65].value).to eq(600)
        end
      end

      context "for incomes of 60k or less" do
        let(:nj_taxable_income) { 60_000 }
        it 'returns 400' do
          expect(instance.lines[:NJ1040_LINE_65].value).to eq(400)
        end
      end

      context "for incomes of 80k or less" do
        let(:nj_taxable_income) { 80_000 }
        it 'returns 200' do
          expect(instance.lines[:NJ1040_LINE_65].value).to eq(200)
        end
      end
    end

    context 'when all dependents are over 5 years old' do
      let(:intake) { create(:state_file_nj_intake, :df_data_one_dep) }

      it 'returns nil' do
        five_years_one_day = Date.new(MultiTenantService.new(:statefile).current_tax_year - 6, 12, 31)
        intake.synchronize_df_dependents_to_database
        intake.dependents.first.update(dob: five_years_one_day)
        intake.dependents.reload
        allow(instance).to receive(:calculate_line_42).and_return 10_000
        instance.calculate
        expect(intake.dependents.count).to eq(1)
        expect(instance.lines[:NJ1040_LINE_65].value).to eq(nil)
        expect(instance.lines[:NJ1040_LINE_65_DEPENDENTS].value).to eq(0)
      end
    end

    context 'with multiple dependents, some of whom are under 5 years old' do
      let(:intake) { create(:state_file_nj_intake, :df_data_many_deps) }

      context 'with 1 dependent' do
        before do
          five_years = Date.new(MultiTenantService.new(:statefile).current_tax_year - 5, 1, 1)
          five_years_one_day = Date.new(MultiTenantService.new(:statefile).current_tax_year - 6, 12, 31)
          intake.synchronize_df_dependents_to_database
          intake.dependents.each do |d| d.update(dob: five_years_one_day) end
          intake.dependents.first.update(dob: five_years)
          intake.dependents.reload
        end
        
        it 'returns 1000 for 1 eligible dependent and a taxable income of 10k' do
          allow(instance).to receive(:calculate_line_42).and_return 10_000
          instance.calculate
          expect(intake.dependents.count).to eq(11)
          expect(instance.lines[:NJ1040_LINE_65].value).to eq(1000)
          expect(instance.lines[:NJ1040_LINE_65_DEPENDENTS].value).to eq(1)
        end

        it 'returns 800 for 1 eligible dependent and a taxable income of 40k' do
          allow(instance).to receive(:calculate_line_42).and_return 40_000
          instance.calculate
          expect(intake.dependents.count).to eq(11)
          expect(instance.lines[:NJ1040_LINE_65].value).to eq(800)
          expect(instance.lines[:NJ1040_LINE_65_DEPENDENTS].value).to eq(1)
        end
      end

      context 'with 11 dependents' do
        before do
          five_years = Date.new(MultiTenantService.new(:statefile).current_tax_year - 5, 1, 1)
          intake.synchronize_df_dependents_to_database
          intake.dependents.each do |d| d.update(dob: five_years) end
          intake.dependents.reload
        end

        it 'returns $9000 ($1000*9) for 11 eligible dependents (reduced to max 9) and a taxable income of 10k' do
          allow(instance).to receive(:calculate_line_42).and_return 10_000
          instance.calculate
          expect(instance.lines[:NJ1040_LINE_65].value).to eq(9_000)
          expect(instance.lines[:NJ1040_LINE_65_DEPENDENTS].value).to eq(9)
        end

        it 'returns $7200 ($800*9) for 11 dependents (reduced to max 9) and a taxable income of 40k' do
          allow(instance).to receive(:calculate_line_42).and_return 40_000
          instance.calculate
          expect(instance.lines[:NJ1040_LINE_65].value).to eq(7_200)
          expect(instance.lines[:NJ1040_LINE_65_DEPENDENTS].value).to eq(9)
        end
      end
    end
  end
end
