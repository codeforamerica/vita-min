require 'rails_helper'

describe Efile::Md::Md502Calculator do
  let(:filing_status) { "single" }
  let(:intake) { create(:state_file_md_intake, filing_status: filing_status) }
  let(:instance) do
    described_class.new(
      year: MultiTenantService.statefile.current_tax_year,
      intake: intake
    )
  end

  describe "#calculate_line_1e" do
    let(:filing_status) { "single" }

    context 'when total interest is greater than $11,600' do
      before do
        intake.direct_file_data.fed_taxable_income = 11_599
        intake.direct_file_data.fed_tax_exempt_interest = 2
      end

      it 'returns true' do
        instance.calculate
        expect(instance.lines[:MD502_LINE_1E].value).to be_truthy
      end
    end

    context 'when total interest is less than or equal to $11,600' do
      before do
        intake.direct_file_data.fed_taxable_income = 11_599
        intake.direct_file_data.fed_tax_exempt_interest = 1
      end

      it 'returns true' do
        instance.calculate
        expect(instance.lines[:MD502_LINE_1E].value).to be_falsey
      end
    end
  end

  describe "#calculate_md502_cr_part_b_line_3" do
    before do
      intake.direct_file_data.fed_agi = agi
      instance.calculate
    end

    context "when filer is non-mfj" do
      let(:filing_status) { "single" }

      context "the agi is negative" do
        let(:agi) { -10 }
        it 'returns the correct decimal value' do
          expect(instance.lines[:MD502CR_PART_B_LINE_3].value).to eq(0.32)
        end
      end

      context "the agi is 0" do
        let(:agi) { 0 }
        it 'returns the correct decimal value' do
          expect(instance.lines[:MD502CR_PART_B_LINE_3].value).to eq(0.32)
        end
      end

      context "the agi is 90,001" do
        let(:agi) { 90_001 }
        it 'returns the correct decimal value' do
          expect(instance.lines[:MD502CR_PART_B_LINE_3].value).to eq(0.2208)
        end
      end

      context "the agi is over $103,651" do
        let(:agi) { 103_651 }
        it 'returns the correct decimal value' do
          expect(instance.lines[:MD502CR_PART_B_LINE_3].value).to eq(0.000)
        end
      end
    end

    context "when filer is mfj" do
      let(:filing_status) { "married_filing_jointly" }

      context 'the agi is $62,001' do
        let(:agi) { 62_001 }
        it 'returns the correct decimal value' do
          expect(instance.lines[:MD502CR_PART_B_LINE_3].value).to eq(0.3040)
        end
      end

      context 'the agi is $161,1001' do
        let(:agi) { 161_101 }
        it 'returns the correct decimal value' do
          expect(instance.lines[:MD502CR_PART_B_LINE_3].value).to eq(0.000)
        end
      end
    end
  end

  describe '#calculate_md502_cr_part_b_line_4' do
    let(:filing_status) { "single" }

    before do
      intake.direct_file_data.fed_agi = 10
      intake.direct_file_data.fed_credit_for_child_and_dependent_care_amount = 10
      instance.calculate
    end

    it 'returns the correct decimal value' do
      expect(instance.lines[:MD502CR_PART_B_LINE_4].value).to eq(3)
    end
  end

  describe '#calculate_md502_cr_part_m_line_1' do
    context "when filing status is mfj, qss or hoh" do
      let(:filing_status) { "married_filing_jointly" }
      context "when filer is 65 or older" do
        before do
          intake.primary_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 65, 1, 1)
        end
        context "when spouse is 65 or older" do
          before do
            intake.spouse_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 65, 1, 1)
          end
          context "when agi <= $150,000" do
            before do
              intake.direct_file_data.fed_agi = 150_000
              instance.calculate
            end
            it "awards a credit of $1750" do
              expect(instance.lines[:MD502CR_PART_M_LINE_1].value).to eq(1_750)
            end
          end
          context "when agi > $150,000" do
            before do
              intake.direct_file_data.fed_agi = 150_001
              instance.calculate
            end
            it "awards no credit" do
              expect(instance.lines[:MD502CR_PART_M_LINE_1].value).to eq(0)
            end
          end
        end
        context "when spouse is under 65" do
          before do
            intake.spouse_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 64, 1, 1)
          end
          context "when agi <= $150,000" do
            before do
              intake.direct_file_data.fed_agi = 150_000
              instance.calculate
            end
            it "awards a credit of $1000" do
              expect(instance.lines[:MD502CR_PART_M_LINE_1].value).to eq(1_000)
            end
          end
          context "when agi > $150,000" do
            before do
              intake.direct_file_data.fed_agi = 150_001
              instance.calculate
            end
            it "awards no credit" do
              expect(instance.lines[:MD502CR_PART_M_LINE_1].value).to eq(0)
            end
          end
        end
      end
      context "when filer is under 65" do
        before do
          intake.primary_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 64, 1, 1)
        end
        context "when spouse is 65 or older" do
          before do
            intake.spouse_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 65, 1, 1)
          end
          context "when agi <= $150,000" do
            before do
              intake.direct_file_data.fed_agi = 150_000
              instance.calculate
            end
            it "awards a credit of $1000" do
              expect(instance.lines[:MD502CR_PART_M_LINE_1].value).to eq(1_000)
            end
          end
          context "when agi > $150,000" do
            before do
              intake.direct_file_data.fed_agi = 150_001
              instance.calculate
            end
            it "awards no credit" do
              expect(instance.lines[:MD502CR_PART_M_LINE_1].value).to eq(0)
            end
          end
        end
        context "when spouse is under 65" do
          before do
            intake.spouse_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 64, 1, 1)
          end
          context "when agi <= $150,000" do
            before do
              intake.direct_file_data.fed_agi = 150_000
              instance.calculate
            end
            it "awards no credit" do
              expect(instance.lines[:MD502CR_PART_M_LINE_1].value).to eq(0)
            end
          end
          context "when agi > $150,000" do
            before do
              intake.direct_file_data.fed_agi = 150_001
              instance.calculate
            end
            it "awards no credit" do
              expect(instance.lines[:MD502CR_PART_M_LINE_1].value).to eq(0)
            end
          end
        end
      end
    end
    context "when filing status is single or mfs" do
      let(:filing_status) { "single" }
      context "when filer is 65 or older" do
        before do
          intake.primary_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 65, 1, 1)
        end
        context "when agi <= $100,000" do
          before do
            intake.direct_file_data.fed_agi = 100_000
            instance.calculate
          end
          it "awards a credit of $1750" do
            expect(instance.lines[:MD502CR_PART_M_LINE_1].value).to eq(1_000)
          end
        end
        context "when agi > $100,000" do
          before do
            intake.direct_file_data.fed_agi = 100_001
            instance.calculate
          end
          it "awards no credit" do
            expect(instance.lines[:MD502CR_PART_M_LINE_1].value).to eq(0)
          end
        end
      end
      context "when filer is under 65" do
        before do
          intake.primary_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 64, 1, 1)
        end
        context "when agi <= $100,000" do
          before do
            intake.direct_file_data.fed_agi = 100_000
            instance.calculate
          end
          it "awards no credit" do
            expect(instance.lines[:MD502CR_PART_M_LINE_1].value).to eq(0)
          end
        end
        context "when agi > $100,000" do
          before do
            intake.direct_file_data.fed_agi = 100_001
            instance.calculate
          end
          it "awards no credit" do
            expect(instance.lines[:MD502CR_PART_M_LINE_1].value).to eq(0)
          end
        end
      end
    end
  end

  describe "#calculate_line_a_primary" do
    context 'primary not claimed as a dependent' do
      before do
        intake.direct_file_data.primary_claim_as_dependent = ""
      end

      it "checks the value" do
        instance.calculate
        expect(instance.lines[:MD502_LINE_A_PRIMARY].value).to eq "X"
      end
    end

    context 'primary is claimed as a dependent' do
      before do
        intake.direct_file_data.primary_claim_as_dependent = "X"
      end

      it "returns nil" do
        instance.calculate
        expect(instance.lines[:MD502_LINE_A_PRIMARY].value).to eq nil
      end
    end
  end

  describe "#calculate_line_a_spouse" do
    context 'married filing jointly' do
      before do
        intake.direct_file_data.filing_status = 2 # married_filing_jointly
      end

      it "checks the value" do
        instance.calculate
        expect(instance.lines[:MD502_LINE_A_SPOUSE].value).to eq "X"
      end
    end

    context 'not married filing jointly' do
      before do
        intake.direct_file_data.filing_status = 1 # single
      end

      it "returns nil" do
        instance.calculate
        expect(instance.lines[:MD502_LINE_A_SPOUSE].value).to eq nil
      end
    end
  end

  describe "#calculate_line_a_count" do
    context "when line a yourself and spouse are both checked" do
      before do
        intake.direct_file_data.filing_status = 2 # married_filing_jointly
        intake.direct_file_data.primary_claim_as_dependent = ""
      end

      it "returns 2" do
        instance.calculate
        expect(instance.lines[:MD502_LINE_A_COUNT].value).to eq 2
      end
    end

    context "when line a yourself is checked but spouse isn't" do
      before do
        intake.direct_file_data.filing_status = 1 # single
        intake.direct_file_data.primary_claim_as_dependent = ""
      end

      it "returns 1" do
        instance.calculate
        expect(instance.lines[:MD502_LINE_A_COUNT].value).to eq 1
      end
    end

    context "when line a yourself and spouse isn't checked" do
      before do
        intake.direct_file_data.filing_status = 1 # single
        intake.direct_file_data.primary_claim_as_dependent = "X"
      end

      it "returns 1" do
        instance.calculate
        expect(instance.lines[:MD502_LINE_A_COUNT].value).to eq 0
      end
    end
  end

  describe "#calculate_line_a_amount" do
    context "when primary or spouse is claimed as a dependent" do
      before do
        intake.direct_file_data.filing_status = 6 # dependent
      end

      it "returns 0" do
        instance.calculate
        expect(instance.lines[:MD502_LINE_A_AMOUNT].value).to eq 0
      end
    end

    context "when filing status single and fed agi is 50_000" do
      before do
        intake.direct_file_data.filing_status = 1 # single
        intake.direct_file_data.fed_agi = 125_001
      end

      it "returns 800" do
        instance.calculate
        expect(instance.lines[:MD502_LINE_A_AMOUNT].value).to eq 800
      end
    end

    context "when filing status hoh and fed agi is negative" do
      before do
        intake.direct_file_data.filing_status = 4 # hoh
        intake.direct_file_data.fed_agi = -3_000
      end

      it "returns 3_200" do
        instance.calculate
        expect(instance.lines[:MD502_LINE_A_AMOUNT].value).to eq 3_200
      end
    end
  end

  describe "#calculate_line_b_primary_senior" do
    context "when primary is 65+" do
      before do
        intake.primary_birth_date = Date.new((MultiTenantService.statefile.current_tax_year - 65), 12, 31)
      end

      it "returns X" do
        instance.calculate
        expect(instance.lines[:MD502_LINE_B_PRIMARY_SENIOR].value).to eq "X"
      end
    end

    context "when primary is 65 the day after the current tax year" do
      # Maryland, unlike other states that follow federal guidelines, does not include Jan 1st b-days for senior benefits
      before do
        intake.primary_birth_date = Date.new((MultiTenantService.statefile.current_tax_year - 64), 1, 1)
      end

      it "returns nil" do
        instance.calculate
        expect(instance.lines[:MD502_LINE_B_PRIMARY_SENIOR].value).to eq nil
      end
    end

    context "when primary is 30 years old at the end of the tax year" do
      # Maryland, unlike other states that follow federal guidelines, does not include Jan 1st b-days for senior benefits
      before do
        intake.primary_birth_date = Date.new((MultiTenantService.statefile.current_tax_year - 30), 12, 31)
      end

      it "returns nil" do
        instance.calculate
        expect(instance.lines[:MD502_LINE_B_PRIMARY_SENIOR].value).to eq nil
      end
    end
  end

  describe "#calculate_line_b_spouse_senior" do
    let(:intake) { create(:state_file_md_intake, :with_spouse, filing_status: filing_status) }
    context "when married filed jointly" do
      let(:filing_status) { "married_filing_jointly" }
      context "when spouse is 65+ at the end of the current tax year" do
        before do
          intake.spouse_birth_date = Date.new((MultiTenantService.statefile.current_tax_year - 70), 12, 31)
        end

        it "returns the checked value" do
          instance.calculate
          expect(instance.lines[:MD502_LINE_B_SPOUSE_SENIOR].value).to eq 'X'
        end
      end

      context "when spouse is younger than 65" do
        before do
          intake.spouse_birth_date = Date.new((MultiTenantService.statefile.current_tax_year - 64), 1, 1)
        end

        it "returns nil" do
          instance.calculate
          expect(instance.lines[:MD502_LINE_B_SPOUSE_SENIOR].value).to eq nil
        end
      end
    end

    context "when qualifying widow" do
      let(:filing_status) { "qualifying_widow" }
      context "when spouse is 65+ at the end of the current tax year" do
        before do
          intake.spouse_birth_date = Date.new((MultiTenantService.statefile.current_tax_year - 70), 12, 31)
        end

        it "returns the checked value" do
          instance.calculate
          expect(instance.lines[:MD502_LINE_B_SPOUSE_SENIOR].value).to eq 'X'
        end
      end

      context "when spouse is younger than 65" do
        before do
          intake.spouse_birth_date = Date.new((MultiTenantService.statefile.current_tax_year - 64), 1, 1)
        end

        it "returns nil" do
          instance.calculate
          expect(instance.lines[:MD502_LINE_B_SPOUSE_SENIOR].value).to eq nil
        end
      end
    end

    context "when single" do
      let(:filing_status) { "single" }
      context "when spouse is 65+ at the end of the current tax year" do
        before do
          intake.spouse_birth_date = Date.new((MultiTenantService.statefile.current_tax_year - 70), 12, 31)
        end

        it "returns nil" do
          instance.calculate
          expect(instance.lines[:MD502_LINE_B_SPOUSE_SENIOR].value).to eq nil
        end
      end

      context "when spouse is younger than 65" do
        before do
          intake.spouse_birth_date = Date.new((MultiTenantService.statefile.current_tax_year - 64), 1, 1)
        end

        it "returns nil" do
          instance.calculate
          expect(instance.lines[:MD502_LINE_B_SPOUSE_SENIOR].value).to eq nil
        end
      end
    end

  end

  describe "#calculate_line_b_primary_blind" do
    context "when primary is blind" do
      before do
        allow(intake.direct_file_data).to receive(:is_primary_blind?).and_return true
      end

      it "returns the checked value" do
        instance.calculate
        expect(instance.lines[:MD502_LINE_B_PRIMARY_BLIND].value).to eq 'X'
      end
    end

    context "when primary is NOT blind" do
      before do
        allow(intake.direct_file_data).to receive(:is_primary_blind?).and_return false
      end

      it "returns nil" do
        instance.calculate
        expect(instance.lines[:MD502_LINE_B_PRIMARY_BLIND].value).to eq nil
      end
    end
  end

  describe "#calculate_line_b_spouse_blind" do
    context "when married-filing-jointly" do
      let(:filing_status) { "married_filing_jointly" }
      context "when spouse is blind" do
        before do
          allow(intake.direct_file_data).to receive(:is_spouse_blind?).and_return true
        end

        it "returns the checked value" do
          instance.calculate
          expect(instance.lines[:MD502_LINE_B_SPOUSE_BLIND].value).to eq 'X'
        end
      end

      context "when spouse is NOT blind" do
        before do
          allow(intake.direct_file_data).to receive(:is_spouse_blind?).and_return false
        end

        it "returns nil" do
          instance.calculate
          expect(instance.lines[:MD502_LINE_B_SPOUSE_BLIND].value).to eq nil
        end
      end
    end

    context "when single" do
      context "when spouse is blind" do
        before do
          allow(intake.direct_file_data).to receive(:is_spouse_blind?).and_return true
        end

        it "returns nil" do
          instance.calculate
          expect(instance.lines[:MD502_LINE_B_SPOUSE_BLIND].value).to eq nil
        end
      end

      context "when spouse is NOT blind" do
        before do
          allow(intake.direct_file_data).to receive(:is_spouse_blind?).and_return false
        end

        it "returns nil" do
          instance.calculate
          expect(instance.lines[:MD502_LINE_B_SPOUSE_BLIND].value).to eq nil
        end
      end
    end
  end

  describe "#calculate_line_b_count" do
    context "when all line b boxes checked" do
      before do
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_b_primary_senior).and_return 'X'
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_b_spouse_senior).and_return 'X'
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_b_primary_blind).and_return 'X'
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_b_spouse_blind).and_return 'X'
      end

      it 'returns 4' do
        instance.calculate
        expect(instance.lines[:MD502_LINE_B_COUNT].value).to eq 4
      end
    end

    context "when only 2 line b boxes checked" do
      before do
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_b_primary_senior).and_return 'X'
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_b_spouse_senior).and_return nil
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_b_primary_blind).and_return nil
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_b_spouse_blind).and_return 'X'
      end

      it 'returns 2' do
        instance.calculate
        expect(instance.lines[:MD502_LINE_B_COUNT].value).to eq 2
      end
    end
  end

  describe "#calculate_line_b_amount" do
    before do
      allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_b_count).and_return 2
    end

    it 'returns the checked count times 1000' do
      instance.calculate
      expect(instance.lines[:MD502_LINE_B_AMOUNT].value).to eq 2_000
    end
  end

  describe "#calculate_line_c_count" do
    before do
      allow_any_instance_of(Efile::Md::Md502bCalculator).to receive(:calculate_line_3).and_return 2
    end

    it "gets line 3 from 502b" do
      instance.calculate
      expect(instance.lines[:MD502_LINE_C_COUNT].value).to eq 2
    end
  end

  describe "#calculate_line_c_amount" do
    before do
      allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_a_amount).and_return 3_200
      allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_c_count).and_return 3
    end

    it "multiplies the exemption amount by the dependent exemption count" do
      instance.calculate
      expect(instance.lines[:MD502_LINE_C_AMOUNT].value).to eq(3_200 * 3)
    end
  end

  describe "#calculate_line_d_count_total" do
    before do
      allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_a_count).and_return "1"
      allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_b_count).and_return "2"
      allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_c_count).and_return '3'
    end

    it 'the sums the counts from line A-C' do
      instance.calculate
      expect(instance.lines[:MD502_LINE_D_COUNT_TOTAL].value).to eq 6
    end
  end

  describe "#calculate_line_d_amount_total" do
    before do
      allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_a_amount).and_return nil
      allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_b_amount).and_return 2000
      allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_c_amount).and_return 1200
    end

    it 'the sums the amount from line A-C' do
      instance.calculate
      expect(instance.lines[:MD502_LINE_D_AMOUNT_TOTAL].value).to eq 3200
    end
  end
end
