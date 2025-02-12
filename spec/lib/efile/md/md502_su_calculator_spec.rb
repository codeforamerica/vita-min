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

  describe "#calculate_military_per_filer" do
    context "when the taxable amount is higher than the age benefit amount" do
      before do
        allow_any_instance_of(StateFileMdIntake).to receive(:sum_1099_r_followup_type_for_filer).and_return 30_000
        allow_any_instance_of(StateFileMdIntake).to receive(:is_filer_55_and_older?).and_return is_55_and_older
      end

      context "when the filer is older than 55" do
        let(:is_55_and_older) { true }
        it "returns 20,000" do
          expect(instance.calculate_military_per_filer(:primary)).to eq(20_000)
          expect(instance.calculate_military_per_filer(:spouse)).to eq(20_000)
        end
      end

      context "when the filer is younger than 55" do
        let(:is_55_and_older) { false }
        it "returns 12,500" do
          expect(instance.calculate_military_per_filer(:primary)).to eq(12_500)
          expect(instance.calculate_military_per_filer(:spouse)).to eq(12_500)
        end
      end
    end

    context "when the taxable amount is lower than the age benefit amount" do
      before do
        allow_any_instance_of(StateFileMdIntake).to receive(:sum_1099_r_followup_type_for_filer).and_return 10_000
        allow_any_instance_of(StateFileMdIntake).to receive(:is_filer_55_and_older?).and_return false
      end
      it "returns the taxable amount" do
        expect(instance.calculate_military_per_filer(:primary)).to eq(10_000)
        expect(instance.calculate_military_per_filer(:spouse)).to eq(10_000)
      end
    end
  end

  describe "#calculate_public_safety_employee" do
    before do
      allow_any_instance_of(StateFileMdIntake).to receive(:is_filer_55_and_older?).and_return is_55_and_older
    end

    context "when the age is lower than 55" do
      let(:is_55_and_older) { false }
      it "returns 0" do
        expect(instance.calculate_public_safety_employee(:primary)).to eq(0)
        expect(instance.calculate_public_safety_employee(:spouse)).to eq(0)
      end
    end

    context "when the age is older than 55" do
      let(:is_55_and_older) { true }
      before do
        allow_any_instance_of(StateFileMdIntake).to receive(:sum_two_1099_r_followup_types_for_filer).and_return followup_sum
      end

      context "when the total taxable amount of the applicable followups is less 15,000" do
        let(:followup_sum) { 14_999 }
        it "returns the total taxable amount of the followups" do
          expect(instance.calculate_public_safety_employee(:primary)).to eq(14_999)
          expect(instance.calculate_public_safety_employee(:spouse)).to eq(14_999)
        end
      end

      context "when the total taxable amount of the applicable followups is more than 15,000" do
        let(:followup_sum) { 15_001 }

        it "returns 15,000" do
          expect(instance.calculate_public_safety_employee(:primary)).to eq(15_000)
          expect(instance.calculate_public_safety_employee(:spouse)).to eq(15_000)
        end
      end
    end
  end

  describe "#calculate_line_u_primary" do
    before do
      allow(instance).to receive(:calculate_military_per_filer).with(:primary).and_return 10_000
    end

    it "returns the value for #calculate_military_per_filer" do
      expect(instance.calculate_line_u_primary).to eq(10_000)
    end
  end

  describe "#calculate_line_u_spouse" do
    before do
      allow(instance).to receive(:calculate_military_per_filer).with(:spouse).and_return 10_000
    end

    context "when a single filer" do
      it "returns 0" do
        expect(instance.calculate_line_u_spouse).to eq(0)
      end
    end

    context "when mfj" do
      let(:intake) { create(:state_file_md_intake, :with_spouse) }
      it "returns the value for #calculate_military_per_filer" do
        expect(instance.calculate_line_u_spouse).to eq(10_000)
      end
    end
  end

  describe "#calculate_line_v_primary" do
    before do
      allow(instance).to receive(:calculate_public_safety_employee).with(:primary).and_return 10_000
    end

    it "returns the value for #calculate_public_safety_employee" do
      expect(instance.calculate_line_v_primary).to eq(10_000)
    end
  end

  describe "#calculate_line_v_spouse" do
    before do
      allow(instance).to receive(:calculate_public_safety_employee).with(:spouse).and_return 10_000
    end

    context "when a single filer" do
      it "returns 0" do
        expect(instance.calculate_line_v_spouse).to eq(0)
      end
    end

    context "when mfj" do
      let(:intake) { create(:state_file_md_intake, :with_spouse) }
      it "returns the value for #calculate_public_safety_employee" do
        expect(instance.calculate_line_v_spouse).to eq(10_000)
      end
    end
  end

  describe "#calculate_line_u" do
    before do
      allow(instance).to receive(:calculate_line_u_primary).and_return(15_000)
      allow(instance).to receive(:calculate_line_u_spouse).and_return(20_000)
    end

    it "sums the primary and spouse line u calculations" do
      instance.calculate
      expect(instance.lines[:MD502_SU_LINE_U].value).to eq(35_000)
    end
  end

  describe "#calculate_line_v" do
    before do
      allow(instance).to receive(:calculate_line_v_primary).and_return(15_000)
      allow(instance).to receive(:calculate_line_v_spouse).and_return(20_000)
    end

    it "sums the primary and spouse line u calculations" do
      instance.calculate
      expect(instance.lines[:MD502_SU_LINE_V].value).to eq(35_000)
    end
  end


  describe 'line 1' do
    it 'totals lines a through yc' do
      allow(instance).to receive(:calculate_line_ab).and_return 100
      allow(instance).to receive(:calculate_line_u).and_return 100
      instance.calculate
      expect(instance.lines[:MD502_SU_LINE_1].value).to eq(200)
    end
  end
end
