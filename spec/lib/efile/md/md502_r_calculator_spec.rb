require 'rails_helper'

describe Efile::Md::Md502RCalculator do
  let(:filing_status) { "single" }
  # df_data_2_w2s has $8000 in federal social security benefits
  let(:intake) { create(:state_file_md_intake, :df_data_2_w2s, filing_status: filing_status) }
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

  [
    ['1a', :primary, :spouse, :pension_annuity_endowment, :other],
    ['1b', :spouse, :primary, :pension_annuity_endowment, :other],
    ['7a', :primary, :spouse, :other, :pension_annuity_endowment],
    ['7b', :spouse, :primary, :other, :pension_annuity_endowment],
  ].each do |line, recipient, not_recipient, income_source_to_sum, income_source_to_reject|
    describe "#calculate_line_#{line}" do
      let(:line_key) { "MD502R_LINE_#{line.upcase}" }

      context "with 1099rs" do
        let(:income_source) { income_source_to_sum }
        let(:other_income_source) { income_source_to_reject }
        let!(:state_1099r_followup) do
          create(
            :state_file_md1099_r_followup,
            income_source: income_source,
            state_file1099_r: create(:state_file1099_r, taxable_amount: 25, intake: intake, recipient_ssn: intake.send(recipient).ssn)
          )
        end
        let!(:other_1099r_followup) {
          create(
            :state_file_md1099_r_followup,
            income_source: other_income_source,
            state_file1099_r: create(:state_file1099_r, taxable_amount: 50, intake: intake, recipient_ssn: intake.send(recipient).ssn)
          )
        }

        before do
          main_calculator.calculate
        end

        context "with multiple pension_annunity_endowment 1099rs" do
          let(:other_income_source) { income_source_to_sum }

          it "should add up all 1099r taxable_amount if all have pension_annuity_endowment income_source" do
            expect(instance.lines[line_key].value).to eq 75
          end
        end

        context "with only a single pension_annuity_endowment" do
          it "should only return taxable_amount of 1099r with pension_annuity_endowment income_source" do
            expect(instance.lines[line_key].value).to eq 25
          end
        end

        context "with no single pension_annuity_endowment" do
          let(:income_source) { income_source_to_reject }

          it "should return 0" do
            expect(instance.lines[line_key].value).to eq 0
          end
        end
      end

      context "with only 1099rs of spouse" do
        let!(:state_1099r_followup) do
          create(
            :state_file_md1099_r_followup,
            income_source: income_source_to_sum,
            state_file1099_r: create(:state_file1099_r, taxable_amount: 25, intake: intake, recipient_ssn: intake.send(not_recipient).ssn)
          )
        end

        it "returns nil" do
          expect(instance.lines[line_key]).to be_nil
        end
      end

      context "with no 1099rs" do
        it "returns nil" do
          expect(instance.lines[line_key]).to be_nil
        end
      end
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


