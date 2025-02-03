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

  describe '#calculate_military_taxable_amount' do
    let!(:intake) { create(:state_file_md_intake, :with_spouse) }
    let!(:state_file_1099_r_without_followup) {
      create(
      :state_file1099_r,
      taxable_amount: 1_000,
      intake: intake)
    }
    let!(:state_file_md1099_r_followup_with_military_service_for_primary_1) do
      create(
        :state_file_md1099_r_followup,
        service_type: "military",
        state_file1099_r: create(:state_file1099_r, taxable_amount: 1_000, intake: intake, recipient_ssn: intake.primary.ssn)
      )
    end
    let!(:state_file_md1099_r_followup_with_military_service_for_primary_2) do
      create(
        :state_file_md1099_r_followup,
        service_type: "military",
        state_file1099_r: create(:state_file1099_r, taxable_amount: 1_500, intake: intake, recipient_ssn: intake.primary.ssn)
      )
    end
    let!(:state_file_md1099_r_followup_with_military_service_for_spouse) do
      create(
        :state_file_md1099_r_followup,
        service_type: "military",
        state_file1099_r: create(:state_file1099_r, taxable_amount: 2_000, intake: intake, recipient_ssn: intake.spouse.ssn)
      )
    end
    let!(:state_file_md1099_r_followup_without_military) do
      create(
        :state_file_md1099_r_followup,
        service_type: "none",
        state_file1099_r: create(:state_file1099_r, taxable_amount: 1_000, intake: intake)
      )
    end
    it "totals the military retirement income" do
      expect(instance.calculate_military_taxable_amount(:primary)).to eq(2_500)
      expect(instance.calculate_military_taxable_amount(:spouse)).to eq(2_000)
    end
  end

  describe "#calculate_military_per_person" do
    context "when the taxable amount is higher than the age calculation" do
      before do
        allow(instance).to receive(:calculate_military_taxable_amount).and_return 30_000
        allow_any_instance_of(StateFileMdIntake).to receive(:is_filer_55_and_older?).and_return is_55_and_older
      end

      context "when the filer is older than 55" do
        let(:is_55_and_older) { true }
        it "returns 20,000" do
          expect(instance.calculate_military_per_person(:primary)).to eq(20_000)
          expect(instance.calculate_military_per_person(:spouse)).to eq(20_000)
        end
      end

      context "when the filer is younger than 55" do
        let(:is_55_and_older) { false }
        it "returns 12,500" do
          expect(instance.calculate_military_per_person(:primary)).to eq(12_500)
          expect(instance.calculate_military_per_person(:spouse)).to eq(12_500)
        end
      end
    end

    context "when the taxable amount is lower than the age calculation" do
      before do
        allow(instance).to receive(:calculate_military_taxable_amount).and_return 10_000
        allow_any_instance_of(StateFileMdIntake).to receive(:is_filer_55_and_older?).and_return false
      end
      it "returns the taxable amount" do
        expect(instance.calculate_military_per_person(:primary)).to eq(10_000)
        expect(instance.calculate_military_per_person(:spouse)).to eq(10_000)
      end
    end
  end

  describe "#calculate_line_u_primary" do
    before do
      allow(instance).to receive(:calculate_military_per_person).with(:primary).and_return 10_000
    end

    it "returns the value for #calculate_military_per_person" do
      expect(instance.calculate_line_u_primary).to eq(10_000)
    end
  end

  describe "#calculate_line_u_spouse" do
    before do
      allow(instance).to receive(:calculate_military_per_person).with(:spouse).and_return 10_000
    end

    context "when a single filer" do
      it "returns the value for #calculate_military_per_person" do
        expect(instance.calculate_line_u_spouse).to eq(0)
      end
    end

    context "when mfj" do
      let(:intake) { create(:state_file_md_intake, :with_spouse) }
      it "returns 0" do
        expect(instance.calculate_line_u_spouse).to eq(10_000)
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
      expect(instance.calculate_line_u).to eq(35_000)
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
