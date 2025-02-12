require 'rails_helper'

describe Efile::Md::Md502RCalculator do
  let(:filing_status) { "single" }
  # df_data_2_w2s has $8000 in federal social security benefits
  let(:intake) {
    if filing_status == 'married_filing_jointly'
      create(:state_file_md_intake, :df_data_2_w2s, :with_spouse, filing_status: filing_status)
    else
      create(:state_file_md_intake, :df_data_2_w2s, filing_status: filing_status)
    end
  }
  let(:main_calculator) do
    Efile::Md::Md502Calculator.new(
      year: MultiTenantService.statefile.current_tax_year,
      intake: intake
    )
  end
  let(:instance) { main_calculator.instance_variable_get(:@md502r) }

  describe "#calculate_line_00b_primary_disabled" do
    let(:primary_disabled) { "no" }
    let(:spouse_disabled) { "no" }

    before do
      intake.update(
        primary_disabled: primary_disabled,
        spouse_disabled: spouse_disabled
      )
      main_calculator.calculate
    end

    context "primary filer is disabled" do
      let(:primary_disabled) { "yes" }

      it "returns X" do
        expect(instance.lines[:MD502R_LINE_PRIMARY_DISABLED].value).to eq 'X'
      end
    end

    context "primary filer is not disabled" do
      let(:primary_disabled) { "no" }

      it "returns nil" do
        expect(instance.lines[:MD502R_LINE_SPOUSE_DISABLED].value).to eq nil
      end
    end

    context "spouse filer is disabled" do
      let(:spouse_disabled) { "yes" }

      it "returns nil" do
        expect(instance.lines[:MD502R_LINE_SPOUSE_DISABLED].value).to eq nil
      end
    end

    context "spouse filer is not disabled" do
      let(:spouse_disabled) { "no" }

      it "returns nil" do
        expect(instance.lines[:MD502R_LINE_SPOUSE_DISABLED].value).to eq nil
      end
    end

    context "filing_status mfj" do
      let(:filing_status) { "married_filing_jointly" }

      context "spouse filer is disabled" do
        let(:spouse_disabled) { "yes" }

        it "returns X" do
          expect(instance.lines[:MD502R_LINE_SPOUSE_DISABLED].value).to eq 'X'
        end
      end

      context "spouse filer is not disabled" do
        let(:spouse_disabled) { "no" }

        it "returns nil" do
          expect(instance.lines[:MD502R_LINE_SPOUSE_DISABLED].value).to eq nil
        end
      end
    end
  end

  describe "#calculate_line_1a" do
    before do
      allow_any_instance_of(StateFileMdIntake).to receive(:sum_1099_r_followup_type_for_filer).and_call_original
      allow_any_instance_of(StateFileMdIntake).to receive(:sum_1099_r_followup_type_for_filer).with(:primary, :income_source_pension_annuity_endowment?).and_return 10_000
    end

    it "returns sum of primary filer income from pension_annuity_endowment" do
      main_calculator.calculate
      expect(instance.lines[:MD502R_LINE_1A].value).to eq 10_000
    end
  end

  describe "#calculate_line_1b" do
    before do
      allow_any_instance_of(StateFileMdIntake).to receive(:sum_1099_r_followup_type_for_filer).and_call_original
      allow_any_instance_of(StateFileMdIntake).to receive(:sum_1099_r_followup_type_for_filer).with(:spouse, :income_source_pension_annuity_endowment?).and_return 10_000
    end

    it "returns sum of primary filer income from pension_annuity_endowment" do
      main_calculator.calculate
      expect(instance.lines[:MD502R_LINE_1B].value).to eq 10_000
    end
  end

  describe "#calculate_line_7a" do
    before do
      allow_any_instance_of(StateFileMdIntake).to receive(:sum_1099_r_followup_type_for_filer).and_call_original
      allow_any_instance_of(StateFileMdIntake).to receive(:sum_1099_r_followup_type_for_filer).with(:primary, :income_source_other?).and_return 10_000
    end

    it "returns sum of primary filer income from pension_annuity_endowment" do
      main_calculator.calculate
      expect(instance.lines[:MD502R_LINE_7A].value).to eq 10_000
    end
  end

  describe "#calculate_line_7b" do
    before do
      allow_any_instance_of(StateFileMdIntake).to receive(:sum_1099_r_followup_type_for_filer).and_call_original
      allow_any_instance_of(StateFileMdIntake).to receive(:sum_1099_r_followup_type_for_filer).with(:spouse, :income_source_other?).and_return 10_000
    end

    it "returns sum of primary filer income from pension_annuity_endowment" do
      main_calculator.calculate
      expect(instance.lines[:MD502R_LINE_7B].value).to eq 10_000
    end
  end

  describe "#calculate_8" do
    before do
      allow_any_instance_of(described_class).to receive(:calculate_line_1a).and_return 100
      allow_any_instance_of(described_class).to receive(:calculate_line_1b).and_return 200
      allow_any_instance_of(described_class).to receive(:calculate_line_7a).and_return 300
      allow_any_instance_of(described_class).to receive(:calculate_line_7b).and_return 500
    end

    it "sums up all income" do
      main_calculator.calculate
      expect(instance.lines[:MD502R_LINE_8].value).to eq 1100
    end
  end

  describe '#calculate_9a' do
    context 'when filing MFJ with positive federal social security benefits' do
      let(:filing_status) { "married_filing_jointly" }
      before do
        allow(intake.direct_file_data).to receive(:fed_ssb).and_return(100)
        intake.primary_ssb_amount = 600.32
        main_calculator.calculate
      end

      it 'returns primary social security benefits amount from the intake' do
        expect(instance.lines[:MD502R_LINE_9A].value).to eq 600
      end
    end

    context 'when filing MFJ without positive federal social security benefits' do
      let(:filing_status) { "married_filing_jointly" }

      it 'returns primary social security benefits amount from the intake' do
        main_calculator.calculate
        expect(instance.lines[:MD502R_LINE_9A].value).to eq nil
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
        allow(intake.direct_file_data).to receive(:fed_ssb).and_return(100)
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

  describe "#calculate_line_10a" do
    before do
      allow_any_instance_of(Efile::Md::Md502SuCalculator).to receive(:calculate_line_u_primary).and_return(10)
      allow_any_instance_of(Efile::Md::Md502SuCalculator).to receive(:calculate_line_v_primary).and_return(20)
    end

    it "returns the sum of MD502SU Line U and Line V for primary" do
      main_calculator.calculate
      expect(instance.lines[:MD502R_LINE_10A].value).to eq 30
    end
  end

  describe "#calculate_line_10b" do
    before do
      allow_any_instance_of(Efile::Md::Md502SuCalculator).to receive(:calculate_line_u_spouse).and_return(30)
      allow_any_instance_of(Efile::Md::Md502SuCalculator).to receive(:calculate_line_v_spouse).and_return(40)
    end

    it "returns the sum of MD502SU Line U and Line V for spouse" do
      main_calculator.calculate
      expect(instance.lines[:MD502R_LINE_10B].value).to eq 70
    end
  end

  describe "#calculate_line_11a" do
    context "flipper flag is on" do
      before do
        allow(Flipper).to receive(:enabled?).and_call_original
        allow(Flipper).to receive(:enabled?).with(:show_retirement_ui).and_return(true)
      end

      context "when primary qualifies" do
        before do
          allow_any_instance_of(StateFileMdIntake).to receive(:qualifies_for_pension_exclusion?).with(:primary).and_return(true)
          allow_any_instance_of(Efile::Md::Md502RCalculator).to receive(:calculate_line_1a).and_return(100_000)
          allow_any_instance_of(Efile::Md::Md502RCalculator).to receive(:calculate_line_10a).and_return(80_000)
          allow_any_instance_of(Efile::Md::Md502RCalculator).to receive(:calculate_line_9a).and_return(line_9_a_value)
        end

        context "when qualifying_pension_minus_ssn_or_railroad is less than the tentative exclusion" do
          let(:line_9_a_value) { 14_500}
          it "returns the value for qualifying_pension_minus_ssn_or_railroad" do
            main_calculator.calculate
            expect(instance.lines[:MD502R_LINE_11A].value).to eq 20_000
          end
        end

        context "when qualifying_pension_minus_ssn_or_railroad is greater than the tentative exclusion" do
          let(:line_9_a_value) { 24_500}
          it "returns the value for the tentative exclusion" do
            main_calculator.calculate
            expect(instance.lines[:MD502R_LINE_11A].value).to eq 15_000
          end
        end

        context "when the smaller amount is negative" do
          let(:line_9_a_value) { 39_501}
          it "returns 0" do
            main_calculator.calculate
            expect(instance.lines[:MD502R_LINE_11A].value).to eq 0
          end
        end
      end

      context "when the primary does not qualify" do
        before do
          allow_any_instance_of(StateFileMdIntake).to receive(:qualifies_for_pension_exclusion?).with(:primary).and_return(false)
        end

        it "returns 0" do
          main_calculator.calculate
          expect(instance.lines[:MD502R_LINE_11A].value).to eq 0
        end
      end
    end

    context "flipper flag is off" do
      it "returns 0" do
        main_calculator.calculate
        expect(instance.lines[:MD502R_LINE_11A].value).to eq 0
      end
    end
  end

  describe "#calculate_line_11b" do
    context "flipper flag is on" do
      before do
        allow(Flipper).to receive(:enabled?).and_call_original
        allow(Flipper).to receive(:enabled?).with(:show_retirement_ui).and_return(true)
      end

      context "when spouse qualifies" do
        let(:filing_status) { "married_filing_jointly"}

        before do
          allow_any_instance_of(StateFileMdIntake).to receive(:qualifies_for_pension_exclusion?).and_call_original
          allow_any_instance_of(StateFileMdIntake).to receive(:qualifies_for_pension_exclusion?).with(:spouse).and_return(true)
          allow_any_instance_of(Efile::Md::Md502RCalculator).to receive(:calculate_line_1b).and_return(100_000)
          allow_any_instance_of(Efile::Md::Md502RCalculator).to receive(:calculate_line_10b).and_return(80_000)
          allow_any_instance_of(Efile::Md::Md502RCalculator).to receive(:calculate_line_9b).and_return(line_9_b_value)
        end

        context "when qualifying_pension_minus_ssn_or_railroad is less than the tentative exclusion" do
          let(:line_9_b_value) { 14_500}
          it "returns the value for qualifying_pension_minus_ssn_or_railroad" do
            main_calculator.calculate
            expect(instance.lines[:MD502R_LINE_11B].value).to eq 20_000
          end
        end

        context "when qualifying_pension_minus_ssn_or_railroad is greater than the tentative exclusion" do
          let(:line_9_b_value) { 24_500}
          it "returns the value for the tentative exclusion" do
            main_calculator.calculate
            expect(instance.lines[:MD502R_LINE_11B].value).to eq 15_000
          end
        end

        context "when the smaller amount is negative" do
          let(:line_9_b_value) { 39_501}
          it "returns 0" do
            main_calculator.calculate
            expect(instance.lines[:MD502R_LINE_11B].value).to eq 0
          end
        end
      end

      context "when the spouse does not qualify" do
        context "when the filer is not married filing jointly" do
          let(:filing_status) { "single" }
          it "returns 0" do
            main_calculator.calculate
            expect(instance.lines[:MD502R_LINE_11B].value).to eq 0
          end
        end

        context "when the spouse is not qualified for pension exclusion" do
          let(:filing_status) { "married_filing_jointly" }

          before do
            allow_any_instance_of(StateFileMdIntake).to receive(:qualifies_for_pension_exclusion?).and_call_original
            allow_any_instance_of(StateFileMdIntake).to receive(:qualifies_for_pension_exclusion?).with(:spouse).and_return(false)
          end

          it "returns 0" do
            main_calculator.calculate
            expect(instance.lines[:MD502R_LINE_11B].value).to eq 0
          end
        end
      end
    end

    context "flipper flag is off" do
      it "returns 0" do
        main_calculator.calculate
        expect(instance.lines[:MD502R_LINE_11B].value).to eq 0
      end
    end
  end
end
