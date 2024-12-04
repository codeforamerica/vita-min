require 'rails_helper'

describe Efile::Md::Md502Calculator do
  let(:filing_status) { "single" }
  let(:county) { "Allegany" }
  let(:intake) { create(:state_file_md_intake, filing_status: filing_status, residence_county: county) }
  let(:instance) do
    described_class.new(
      year: MultiTenantService.statefile.current_tax_year,
      intake: intake
    )
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
    context 'married filing jointly with a senior spouse' do
      let(:intake) { create(:state_file_md_intake, :with_senior_spouse) }

      it "checks the value for senior spouse" do
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
    context "when line a yourself and spouse are both seniors" do
      let(:intake) { create(:state_file_md_intake, :with_senior_spouse) }

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

    context "when filing status mfj and fed agi is 50_000" do
      let(:intake) { create(:state_file_md_intake, :with_spouse) }
      before do
        intake.direct_file_data.fed_agi = 150_001
      end

      it "returns 3200 (1600 per exemption)" do
        instance.calculate
        expect(instance.lines[:MD502_LINE_A_AMOUNT].value).to eq 3200
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
      let(:intake) { create(:state_file_md_intake, :with_spouse) }
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

  describe "#gross_income_amount" do
    let(:intake) { create(:state_file_md_intake, :head_of_household) } # needs to have fed_taxable_ssb element in order to set it; shelby_hoh has it
    before do
      intake.direct_file_data.fed_agi = 20_000
      intake.direct_file_data.fed_taxable_ssb = 10_000
      allow_any_instance_of(described_class).to receive(:calculate_line_7).and_return 5_000
      allow_any_instance_of(described_class).to receive(:calculate_line_15).and_return 2_500
      instance.calculate
    end

    context "not claimed as dependent" do
      before do
        allow_any_instance_of(DirectFileData).to receive(:claimed_as_dependent?).and_return false
      end

      it "returns (FAGI - taxable SSB) + line 7" do
        expect(instance.gross_income_amount).to eq 15_000
      end
    end

    context "dependent taxpayer" do
      before do
        allow_any_instance_of(DirectFileData).to receive(:claimed_as_dependent?).and_return true
      end

      it "returns (FAGI + line 7) - line 15" do
        expect(instance.gross_income_amount).to eq 22_500
      end
    end
  end

  describe "#calculate_deduction_method" do
    context "taxpayers under 65" do
      let(:primary_birth_date) { 40.years.ago }
      let(:spouse_birth_date) { 41.years.ago }

      {
        single: 14_600,
        dependent: 14_600,
        married_filing_jointly: 29_200,
        married_filing_separately: 14_600,
        head_of_household: 21_900,
        qualifying_widow: 29_200
      }.each do |filing_status, filing_minimum|
        context "#{filing_status}" do
          let(:intake) { create(:state_file_md_intake, primary_birth_date: primary_birth_date, spouse_birth_date: spouse_birth_date, filing_status: filing_status) }
          let(:instance) do
            described_class.new(
              year: MultiTenantService.statefile.current_tax_year,
              intake: intake
            )
          end

          it "returns S when gross income is greater than or equal to state filing minimum" do
            allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:gross_income_amount).and_return filing_minimum
            instance.calculate
            expect(instance.lines[:MD502_DEDUCTION_METHOD].value).to eq "S"
          end

          it "returns N when gross income is less than state filing minimum" do
            allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:gross_income_amount).and_return filing_minimum - 10
            instance.calculate
            expect(instance.lines[:MD502_DEDUCTION_METHOD].value).to eq "N"
          end
        end
      end
    end

    context "taxpayers over 65" do
      context "primary over 65" do
        let(:primary_birth_date) { 66.years.ago }
        let(:spouse_birth_date) { 60.years.ago }

        {
          single: 16_550,
          dependent: 16_550,
          married_filing_jointly: 30_750,
          married_filing_separately: 14_600,
          head_of_household: 23_850,
          qualifying_widow: 30_750
        }.each do |filing_status, filing_minimum|
          context "#{filing_status}" do
            let(:intake) { create(:state_file_md_intake, primary_birth_date: primary_birth_date, spouse_birth_date: spouse_birth_date, filing_status: filing_status) }
            let(:instance) do
              described_class.new(
                year: MultiTenantService.statefile.current_tax_year,
                intake: intake
              )
            end

            it "returns S when gross income is greater than or equal to state filing minimum" do
              allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:gross_income_amount).and_return filing_minimum
              instance.calculate
              expect(instance.lines[:MD502_DEDUCTION_METHOD].value).to eq "S"
            end

            it "returns N when gross income is less than state filing minimum" do
              allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:gross_income_amount).and_return filing_minimum - 10
              instance.calculate
              expect(instance.lines[:MD502_DEDUCTION_METHOD].value).to eq "N"
            end
          end
        end
      end

      context "primary and spouse both over 65" do
        let(:primary_birth_date) { 66.years.ago }
        let(:spouse_birth_date) { 66.years.ago }
        let(:filing_status) { "married_filing_jointly" }
        let(:filing_minimum) { 32_300 }
        let(:intake) { create(:state_file_md_intake, primary_birth_date: primary_birth_date, spouse_birth_date: spouse_birth_date, filing_status: filing_status) }
        let(:submission) { create(:efile_submission, data_source: intake) }
        let(:build_response) { described_class.build(submission, validate: false) }
        let(:xml) { Nokogiri::XML::Document.parse(build_response.document.to_xml) }

        it "returns S when gross income is greater than or equal to state filing minimum" do
          allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:gross_income_amount).and_return filing_minimum
          instance.calculate
          expect(instance.lines[:MD502_DEDUCTION_METHOD].value).to eq "S"
        end

        it "returns N when gross income is less than state filing minimum" do
          allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:gross_income_amount).and_return filing_minimum - 10
          instance.calculate
          expect(instance.lines[:MD502_DEDUCTION_METHOD].value).to eq "N"
        end
      end
    end
  end

  describe "#calculate_line_13" do
    before do
      allow_any_instance_of(Efile::Md::Md502SuCalculator).to receive(:calculate_line_1).and_return 100
    end

    it 'the sums the amount from line A-C' do
      instance.calculate
      expect(instance.lines[:MD502_LINE_13].value).to eq 100
    end
  end

  describe "#calculate_line_14" do
    before do
      allow_any_instance_of(Efile::Md::TwoIncomeSubtractionWorksheet).to receive(:calculate_line_7).and_return 1000
    end

    context 'MFJ filing status' do
      let(:filing_status) { 'married_filing_jointly' }
      it 'returns the amount from the worksheet if MFJ filing status' do
        instance.calculate
        expect(instance.lines[:MD502_LINE_14].value).to eq 1000
      end
    end

    context 'MFS filing status' do
      let(:filing_status) { 'married_filing_separately' }
      it 'returns the 0 if not MFJ filing status' do
        instance.calculate
        expect(instance.lines[:MD502_LINE_14].value).to eq 0
      end
    end
  end

  describe "#calculate_line_15" do
    before do
      intake.direct_file_data.total_qualifying_dependent_care_expenses = 2
      intake.direct_file_data.fed_taxable_ssb = 6
      allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_10a).and_return 4
      allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_13).and_return 8
      allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_14).and_return 10
    end
    it "sums lines 8 - 14" do
      instance.calculate
      expect(instance.lines[:MD502_LINE_15].value).to eq 2 + 4 + 6 + 8 + 10
    end
  end

  describe "#calculate_line_16" do
    before do
      allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_7).and_return 150
      allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_15).and_return 50
    end
    it "subtracts line 15 from line 7" do
      instance.calculate
      expect(instance.lines[:MD502_LINE_16].value).to eq 100
    end
  end

  describe "#calculate_line_17" do
    context "when method is standard" do
      [
        [["single", "married_filing_separately", "dependent"], [
          [12_000, 1_800],
          [17_999, 17_999 * 0.15],
          [18_001, 2_700],
        ]],
        [["married_filing_jointly", "head_of_household", "qualifying_widow"], [
          [24_333, 3_650],
          [36_332, 36_332 * 0.15],
          [36_334, 5_450],
        ]]
      ].each do |filing_statuses, agis_to_deductions|
        filing_statuses.each do |filing_status|
          context "#{filing_status}" do
            before do
              allow_any_instance_of(described_class).to receive(:calculate_deduction_method).and_return "S"
            end

            agis_to_deductions.each do |agi_limit, deduction_amount|
              context "agi is #{agi_limit}" do
                let(:intake) { create(:state_file_md_intake, filing_status: filing_status) }
                let(:calculator_instance) { described_class.new(year: MultiTenantService.statefile.current_tax_year, intake: intake) }

                before do
                  allow_any_instance_of(described_class).to receive(:calculate_line_16).and_return agi_limit
                end

                it "returns the value corresponding to #{agi_limit} MD AGI limit" do
                  calculator_instance.calculate
                  expect(calculator_instance.lines[:MD502_LINE_17].value).to eq(deduction_amount)
                end
              end
            end
          end
        end
      end
    end

    context "non-standard" do
      it "returns 0" do
        allow_any_instance_of(described_class).to receive(:calculate_deduction_method).and_return "N"
        instance.calculate
        expect(instance.lines[:MD502_LINE_17].value).to eq 0
      end
    end
  end

  describe "#calculate_line_18" do
    before do
      allow_any_instance_of(described_class).to receive(:calculate_line_17).and_return 5
      allow_any_instance_of(described_class).to receive(:calculate_line_16).and_return 10
    end

    context "deduction method is standard" do
      it "subtracts line 17 from line 16" do
        allow_any_instance_of(described_class).to receive(:calculate_deduction_method).and_return "S"
        instance.calculate
        expect(instance.lines[:MD502_LINE_18].value).to eq 5
      end
    end

    context "deduction method is non-standard" do
      it "returns 0" do
        allow_any_instance_of(described_class).to receive(:calculate_deduction_method).and_return "N"
        instance.calculate
        expect(instance.lines[:MD502_LINE_18].value).to eq 0
      end
    end
  end

  describe "#calculate_line_19" do
    before do
      allow_any_instance_of(described_class).to receive(:calculate_line_d_amount_total).and_return 50
    end

    context "deduction method is standard" do
      it "copies over total exemption amount" do
        allow_any_instance_of(described_class).to receive(:calculate_deduction_method).and_return "S"
        instance.calculate
        expect(instance.lines[:MD502_LINE_19].value).to eq 50
      end
    end

    context "deduction method is non-standard" do
      it "returns 0" do
        allow_any_instance_of(described_class).to receive(:calculate_deduction_method).and_return "N"
        instance.calculate
        expect(instance.lines[:MD502_LINE_19].value).to eq 0
      end
    end
  end

  describe "#calculate_line_20" do
    before do
      allow_any_instance_of(described_class).to receive(:calculate_line_19).and_return 10
      allow_any_instance_of(described_class).to receive(:calculate_line_18).and_return 20
    end

    context "deduction method is standard" do
      it "subtracts line 19 from line 18" do
        allow_any_instance_of(described_class).to receive(:calculate_deduction_method).and_return "S"
        instance.calculate
        expect(instance.lines[:MD502_LINE_20].value).to eq 10
      end

      it "replaces a negative number with 0" do
        allow_any_instance_of(described_class).to receive(:calculate_line_19).and_return 20
        allow_any_instance_of(described_class).to receive(:calculate_line_18).and_return 10
        allow_any_instance_of(described_class).to receive(:calculate_deduction_method).and_return "S"
        instance.calculate
        expect(instance.lines[:MD502_LINE_20].value).to eq 0
      end
    end

    context "deduction method is non-standard" do
      it "returns 0" do
        allow_any_instance_of(described_class).to receive(:calculate_deduction_method).and_return "N"
        instance.calculate
        expect(instance.lines[:MD502_LINE_20].value).to eq 0
      end
    end
  end

  describe "#calculate_line_3" do
    let!(:first_state_file_w2) { create(:state_file_w2, state_file_intake: intake, box14_stpickup: 100.0) }
    let!(:second_state_file_w2) { create(:state_file_w2, state_file_intake: intake, box14_stpickup: 250.6) }
    let!(:third_state_file_w2) { create(:state_file_w2, state_file_intake: intake, box14_stpickup: nil) }
    context "with w2s" do
      it "returns the sum of all box14_stpickup" do
        instance.calculate
        expect(instance.lines[:MD502_LINE_3].value).to eq 351
      end
    end
  end

  describe "#calculate_line_6" do
    it "returns the total additions" do
      allow_any_instance_of(described_class).to receive(:calculate_line_3).and_return 550
      instance.calculate
      expect(instance.lines[:MD502_LINE_6].value).to eq 550
    end
  end

  describe "#calculate_line_7" do
    before do
      intake.direct_file_data.fed_agi = 100
      allow_any_instance_of(described_class).to receive(:calculate_line_6).and_return 200
      instance.calculate
    end

    it "returns the sum of line 1 and 6" do
      expect(instance.lines[:MD502_LINE_7].value).to eq 300
    end
  end

  describe "#calculate_line_21" do
    let(:taxable_net_income) { 500 }
    let(:deduction_method) { "S" }

    before do
      allow_any_instance_of(described_class).to receive(:calculate_line_20).and_return taxable_net_income
      allow_any_instance_of(described_class).to receive(:calculate_deduction_method).and_return deduction_method
      instance.calculate
    end

    context "deduction method is standard" do
      context "taxable net income is 500" do
        it "MD tax is 10" do
          expect(instance.lines[:MD502_LINE_21].value).to eq 10
        end
      end

      context "taxable net income is 1000" do
        let(:taxable_net_income) { 1000 }
        it "MD tax is 20" do
          expect(instance.lines[:MD502_LINE_21].value).to eq 20
        end
      end

      context "taxable net income is 2500" do
        let(:taxable_net_income) { 2500 }
        it "MD tax is 70" do
          expect(instance.lines[:MD502_LINE_21].value).to eq 70
        end
      end

      context "taxable net income is 3100 and filing status is single" do
        let(:taxable_net_income) { 3100 }
        it "MD tax is 94.75" do
          expect(instance.lines[:MD502_LINE_21].value).to eq 95
        end
      end

      context "taxable net income is 100,500 and filing status is single" do
        let(:taxable_net_income) { 100_500 }
        it "MD tax is 4722.5" do
          expect(instance.lines[:MD502_LINE_21].value).to eq 4723
        end
      end

      context "taxable net income is 130,000 and filing status is single" do
        let(:taxable_net_income) { 130_000 }
        it "MD tax is 6,210" do
          expect(instance.lines[:MD502_LINE_21].value).to eq 6210
        end
      end

      context "taxable net income is 200,000 and filing status is single" do
        let(:taxable_net_income) { 200_000 }
        it "MD tax is 10,010" do
          expect(instance.lines[:MD502_LINE_21].value).to eq 10_010
        end
      end

      context "taxable net income is 300,000 and filing status is single" do
        let(:taxable_net_income) { 300_000 }
        it "MD tax is 15,635" do
          expect(instance.lines[:MD502_LINE_21].value).to eq 15635
        end
      end

      context "filing status is married-filing-jointly" do
        let(:filing_status) { 'married_filing_jointly' }

        context "taxable net income is 125,000" do
          let(:taxable_net_income) { 125_000 }
          it "MD tax is 5,885" do
            expect(instance.lines[:MD502_LINE_21].value).to eq 5_885
          end
        end

        context "taxable net income is 200,000" do
          let(:taxable_net_income) { 200_000 }
          it "MD tax is 9,635" do
            expect(instance.lines[:MD502_LINE_21].value).to eq 9_635
          end
        end

        context "taxable net income is 270,000" do
          let(:taxable_net_income) { 270_000 }
          it "MD tax is 13,423" do
            expect(instance.lines[:MD502_LINE_21].value).to eq 13_423
          end
        end

        context "taxable net income is 1,000,000" do
          let(:taxable_net_income) { 1_000_000 }
          it "MD tax is 55,323" do
            expect(instance.lines[:MD502_LINE_21].value).to eq 55_323
          end
        end
      end
    end

    context "deduction method is 'N'" do
      let(:deduction_method) { "N" }
      it "returns nil" do
        expect(instance.lines[:MD502_LINE_21].value).to eq nil
      end
    end
  end

  describe "#calculate_line_22" do
    let(:filing_status) { "married_filing_jointly" }
    let(:df_xml_key) { "md_laney_qss" }
    let!(:intake) {
      create(
        :state_file_md_intake,
        filing_status: filing_status,
        raw_direct_file_data: StateFile::DirectFileApiResponseSampleService.new.read_xml(df_xml_key)
      )
    }
    let(:federal_eic) { 1001 }

    before do
      intake.direct_file_data.fed_eic = federal_eic
      instance.calculate
    end

    context "when mfj and at least one qualifying child" do
      it 'EIC is half the federal EIC' do
        expect(instance.lines[:MD502_LINE_22].value).to eq 501
      end
    end

    context "when mfj and no qualifying children" do
      let(:df_xml_key) { "md_zeus_two_w2s" }
      it 'EIC is 0' do
        expect(instance.lines[:MD502_LINE_22].value).to eq 501
      end
    end

    context "when single and no qualifying children" do
      let(:filing_status) { "single" }
      let(:df_xml_key) { "md_zeus_two_w2s" }

      it "state EIC is 100% of the federal EIC" do
        expect(instance.lines[:MD502_LINE_22].value).to eq 1001
      end
    end

    context "when filing as a dependent and no qualifying children" do
      let(:filing_status) { "dependent" }
      let(:df_xml_key) { "md_zeus_two_w2s" }
      it 'EIC is nil' do
        expect(instance.lines[:MD502_LINE_22].value).to eq nil
      end
    end
  end

  describe "#calculate_line_22b" do
    let(:df_xml_key) { "md_laney_qss" }
    let!(:intake) {
      create(
        :state_file_md_intake,
        raw_direct_file_data: StateFile::DirectFileApiResponseSampleService.new.read_xml(df_xml_key)
      )
    }
    context "when has at least one qualifying EIC child and MD EIC is over 0" do
      it "returns X" do
        allow_any_instance_of(described_class).to receive(:calculate_line_22).and_return 100
        instance.calculate
        expect(instance.lines[:MD502_LINE_22B].value).to eq "X"
      end
    end

    context "when no qualifying EIC child and MD EIC is over 0" do
      let(:df_xml_key) { "md_zeus_two_w2s" }
      it "returns nil" do
        allow_any_instance_of(described_class).to receive(:calculate_line_22).and_return 100
        instance.calculate
        expect(instance.lines[:MD502_LINE_22B].value).to eq nil
      end
    end

    context "when has at least one qualifying EIC child but MD EIC is 0" do
      it "returns nil" do
        allow_any_instance_of(described_class).to receive(:calculate_line_22).and_return nil
        instance.calculate
        expect(instance.lines[:MD502_LINE_22B].value).to eq nil
      end
    end

    context "when no qualifying EIC child and MD EIC is 0" do
      let(:df_xml_key) { "md_zeus_two_w2s" }
      it "returns nil" do
        allow_any_instance_of(described_class).to receive(:calculate_line_22).and_return nil
        instance.calculate
        expect(instance.lines[:MD502_LINE_22B].value).to eq nil
      end
    end
  end

  describe "#calculate_line_23" do
    before do
      intake.direct_file_data.fed_wages_salaries_tips = line_1b
      allow_any_instance_of(described_class).to receive(:calculate_line_7).and_return(line_7)
      instance.calculate
    end

    context "when filing as dependent" do
      let(:filing_status) { "dependent" }
      let(:line_1b) { 20_000 }
      let(:line_7) { 15_000 }

      it "returns 0" do
        expect(instance.lines[:MD502_LINE_23].value).to eq(0)
      end
    end

    context "when line 1B is not positive" do
      let(:filing_status) { "single" }
      let(:line_1b) { 0 }
      let(:line_7) { 15_000 }

      it "returns 0" do
        expect(instance.lines[:MD502_LINE_23].value).to eq(0)
      end
    end

    context "single filer with no dependents" do
      let(:filing_status) { "single" }
      let(:line_1b) { 14_000 }

      context "when both line_1b and line_7 are below poverty threshold" do
        let(:line_7) { 14_500 } # Max of 1b and 7 below single person house threshold of 15,060

        it "returns 5% of line 1B" do
          expect(instance.lines[:MD502_LINE_23].value).to eq(700)
        end
      end

      context "when either amount is above poverty threshold" do
        let(:line_7) { 15_500 }

        it "returns 0" do
          expect(instance.lines[:MD502_LINE_23].value).to eq(0) # Line 7 above threshold of 15,060
        end
      end
    end

    context "married filing jointly with two dependent" do
      let(:line_1b) { 30_000 }
      let(:filing_status) { "married_filing_jointly" }

      context "when both line_1b and line_7 are below poverty threshold" do
        let(:line_7) { 30_500 } # Max of 1b and 7 is below threshold for family of 4 (31,200)

        it "returns 5% of line 1B" do
          create :state_file_dependent, intake: intake, dob: 7.years.ago
          create :state_file_dependent, intake: intake, dob: 7.years.ago
          instance.calculate
          expect(instance.lines[:MD502_LINE_23].value).to eq(1_500)
        end
      end

      context "when either amount is above poverty threshold" do
        let(:line_7) { 31_500 }

        it "returns 0" do
          create :state_file_dependent, intake: intake, dob: 7.years.ago
          create :state_file_dependent, intake: intake, dob: 7.years.ago
          instance.calculate
          expect(instance.lines[:MD502_LINE_23].value).to eq(0) # line 7 is above threshold for family of 4 (31,200)
        end
      end
    end
  end

  describe "#calculate_line_26" do
    before do
      allow_any_instance_of(described_class).to receive(:calculate_line_22).and_return(100)
      allow_any_instance_of(described_class).to receive(:calculate_line_23).and_return(200)
      allow_any_instance_of(described_class).to receive(:calculate_line_24).and_return(300)
      instance.calculate
    end

    it "returns the sum of lines 22 through 25" do
      expect(instance.lines[:MD502_LINE_26].value).to eq(600)
    end
  end

  describe "#calculate_line_27" do
    before do
      allow_any_instance_of(described_class).to receive(:calculate_line_21).and_return(line_21)
      allow_any_instance_of(described_class).to receive(:calculate_line_26).and_return(line_26)
      instance.calculate
    end

    context "when line_21 minus line_27 is negative" do
      let(:line_21) { 100 }
      let(:line_26) { 150 }

      it "returns 0" do
        expect(instance.lines[:MD502_LINE_27].value).to eq(0)
      end
    end

    context "when line_21 minus line_27 is positive" do
      let(:line_21) { 200 }
      let(:line_26) { 150 }

      it "returns the difference" do
        expect(instance.lines[:MD502_LINE_27].value).to eq(50)
      end
    end
  end

  describe '#calculate_line_40' do
    let(:intake) {
      # Allen has $500 state tax withheld $1000 in local income tax on a w2 & $10 state tax withheld on a 1099r
      create(:state_file_md_intake,
             :with_1099_rs_synced,
             :with_w2s_synced,
             raw_direct_file_data: StateFile::DirectFileApiResponseSampleService.new.read_xml('md_allen_hoh_w2_and_1099r'))
    }
    let!(:state_file1099_g) { create(:state_file1099_g, intake: intake, state_income_tax_withheld_amount: 100) }

    it 'sums the MD tax withheld from w2s, 1099gs and 1099rs' do
      instance.calculate
      expect(instance.lines[:MD502_LINE_40].value).to eq(1610)
    end
  end

  describe "#calculate_line_39" do
    context "when there is a value for line 34" do
      before do
        allow_any_instance_of(described_class).to receive(:calculate_line_34).and_return 500
      end

      it "returns line 34" do
        instance.calculate
        expect(instance.lines[:MD502_LINE_39].value).to eq 500
      end
    end

    context "when line 34 is nil" do
      it "returns 0" do
        allow_any_instance_of(described_class).to receive(:calculate_line_34).and_return nil
        instance.calculate
        expect(instance.lines[:MD502_LINE_39].value).to eq 0
      end
    end
  end

  describe "#calculate_line_28_local_tax_rate" do
    let(:taxable_net_income) { 10_000 }
    before do
      allow_any_instance_of(described_class).to receive(:calculate_line_20).and_return taxable_net_income
      instance.calculate
    end

    context "when the county is Allegany" do
      it "returns 0.0303" do
        expect(instance.lines[:MD502_LINE_28_LOCAL_TAX_RATE].value).to eq(0.0303)
      end
    end

    context "when the county is Anne Arundel" do
      let(:county) { "Anne Arundel" }
      it "returns 0.027" do
        expect(instance.lines[:MD502_LINE_28_LOCAL_TAX_RATE].value).to eq(0.027)
      end
    end

    context "when the county is Frederick" do
      let(:county) { "Frederick" }
      context "filing status is single" do
        let(:filing_status) { "single" }

        context "when taxable net income is 10,000" do
          let(:taxable_net_income) { 10_000 }
          it "return .0225" do
            expect(instance.lines[:MD502_LINE_28_LOCAL_TAX_RATE].value).to eq(0.0225)
          end
        end

        context "when taxable net income is 150,000" do
          let(:taxable_net_income) { 150_000 }
          it "return .0296" do
            expect(instance.lines[:MD502_LINE_28_LOCAL_TAX_RATE].value).to eq(0.0296)
          end
        end

        context "when taxable net income is 200,000" do
          let(:taxable_net_income) { 200_000 }
          it "return .032" do
            expect(instance.lines[:MD502_LINE_28_LOCAL_TAX_RATE].value).to eq(0.032)
          end
        end
      end

      context "filing status is mfj" do
        let(:filing_status) { "married_filing_jointly" }

        context "when taxable net income is 15,000" do
          let(:taxable_net_income) { 15_000 }
          it "return .0225" do
            expect(instance.lines[:MD502_LINE_28_LOCAL_TAX_RATE].value).to eq(0.0225)
          end
        end

        context "when taxable net income is 120,000" do
          let(:taxable_net_income) { 90_000 }
          it "return .0296" do
            expect(instance.lines[:MD502_LINE_28_LOCAL_TAX_RATE].value).to eq(0.0275)
          end
        end

        context "when taxable net income is 200,000" do
          let(:taxable_net_income) { 260_000 }
          it "return .032" do
            expect(instance.lines[:MD502_LINE_28_LOCAL_TAX_RATE].value).to eq(0.032)
          end
        end
      end
    end
  end

  describe "#calculate_line_42" do
    let(:filing_status) { "head_of_household" }
    let(:df_xml_key) { "md_laney_qss" }
    let!(:intake) {
      create(
        :state_file_md_intake,
        filing_status: filing_status,
        raw_direct_file_data: StateFile::DirectFileApiResponseSampleService.new.read_xml(df_xml_key)
      )
    }
    let(:federal_eic) { 1200 }

    before do
      intake.direct_file_data.fed_eic = federal_eic
      allow_any_instance_of(described_class).to receive(:calculate_line_21).and_return 500
      instance.calculate
    end

    context "when there is least one qualifying child" do
      context "when federal EIC * .45 is equal to or greater than Maryland tax (line 21)" do
        it 'refundable EIC equals (federal EIC * .45) - Maryland tax (line 21)' do
          expect(instance.lines[:MD502_LINE_42].value).to eq 40 # .45 of 1200 is 540. 540 - 500
        end
      end

      context "when federal EIC * .45 is less than than Maryland tax (line 21)" do
        before do
          intake.direct_file_data.fed_eic = federal_eic
          allow_any_instance_of(described_class).to receive(:calculate_line_21).and_return 600
          instance.calculate
        end
        it 'refundable EIC is 0' do
          expect(instance.lines[:MD502_LINE_42].value).to eq 0
        end
      end
    end

    context "when mfj and no qualifying children" do
      let(:filing_status) { "married_filing_jointly" }
      let(:df_xml_key) { "md_zeus_two_w2s" }
      it 'refundable EIC equals (federal EIC * .45) - Maryland tax (line 21)' do
        expect(instance.lines[:MD502_LINE_42].value).to eq 40
      end
    end

    context "when single and no qualifying children" do
      let(:filing_status) { "single" }
      let(:df_xml_key) { "md_zeus_two_w2s" }

      context "when federal EIC is equal to or greater than Maryland tax (line 21)" do
        it "refundable EIC equals - Maryland tax (line 21)" do
          expect(instance.lines[:MD502_LINE_42].value).to eq 700
        end
      end

      context "when federal EIC is less than than Maryland tax (line 21)" do
        before do
          intake.direct_file_data.fed_eic = federal_eic
          allow_any_instance_of(described_class).to receive(:calculate_line_21).and_return 1500
          instance.calculate
        end
        it 'refundable EIC is 0' do
          expect(instance.lines[:MD502_LINE_42].value).to eq 0
        end
      end
    end

    context "when filing as a dependent and no qualifying children" do
      let(:filing_status) { "dependent" }
      let(:df_xml_key) { "md_zeus_two_w2s" }
      it 'refundable EIC is nil' do
        expect(instance.lines[:MD502_LINE_42].value).to eq nil
      end
    end
  end

  describe "#calculate_line_28_local_tax_amount" do
    before do
      allow_any_instance_of(described_class).to receive(:calculate_line_20).and_return 300_000
      instance.calculate
    end

    context "when county is Anne Arundel" do
      let(:county) { "Anne Arundel" }
      it "calculates the local tax" do
        expect(instance.lines[:MD502_LINE_28_LOCAL_TAX_AMOUNT].value).to eq(8375)
      end
    end

    context "when the county is Frederick" do
      let(:county) { "Frederick" }
      it "calculates the local tax based on income" do
        expect(instance.lines[:MD502_LINE_28_LOCAL_TAX_AMOUNT].value).to eq(9600)
      end
    end

    context "when the county is Allegany" do
      it "calculates the local tax using progressive brackets" do
        expect(instance.lines[:MD502_LINE_28_LOCAL_TAX_AMOUNT].value).to eq(9090)
      end
    end
  end

  describe "#calculate_line_29" do
    let(:federal_eic) { 1001 }

    before do
      intake.direct_file_data.fed_eic = federal_eic
      allow_any_instance_of(described_class).to receive(:calculate_line_20).and_return 300_000
      instance.calculate
    end

    context "when county is Anne Arundel" do
      let(:county) { "Anne Arundel" }
      it "uses 0.0270 as the local tax rate in the formula" do
        # (0.027 * 10) * 1001
        expect(instance.lines[:MD502_LINE_29].value).to eq(270)
      end
    end

    context "when the county is Frederick" do
      let(:county) { "Frederick" }
      it "uses the tax rate from line 28 in the formula" do
        # (0.032 * 10) * 1001
        expect(instance.lines[:MD502_LINE_29].value).to eq(320)
      end
    end

    context "when the county is Allegany" do
      it "uses the tax rate from line 28 in the formula" do
        # (0.0303 * 10) * 1001
        expect(instance.lines[:MD502_LINE_29].value).to eq(303)
      end
    end
  end

  describe "#calculate_line_44" do
    before do
      allow_any_instance_of(described_class).to receive(:calculate_line_40).and_return 250
      allow_any_instance_of(described_class).to receive(:calculate_line_42).and_return 200
      allow_any_instance_of(described_class).to receive(:calculate_line_43).and_return 150
    end
    it "sums lines 40 to 44" do
      instance.calculate
      expect(instance.lines[:MD502_LINE_44].value).to eq(600)
    end
  end

  describe "#calculate_line_45" do
    context "line 39 is less than 44" do
      before do
        allow_any_instance_of(described_class).to receive(:calculate_line_39).and_return 50
        allow_any_instance_of(described_class).to receive(:calculate_line_44).and_return 150
      end
      it "returns nil" do
        instance.calculate
        expect(instance.lines[:MD502_LINE_45].value).to eq(nil)
      end
    end

    context "line 39 is more than 44" do
      before do
        allow_any_instance_of(described_class).to receive(:calculate_line_39).and_return 1_000
        allow_any_instance_of(described_class).to receive(:calculate_line_44).and_return 900
      end
      it "subtracts line 39 from line 44" do
        instance.calculate
        expect(instance.lines[:MD502_LINE_45].value).to eq(100)
        expect(instance.lines[:MD502_LINE_50].value).to eq(100)
      end
    end
  end

  describe "#calculate_line_46" do
    context "line 39 is less than 44" do
      before do
        allow_any_instance_of(described_class).to receive(:calculate_line_39).and_return 900
        allow_any_instance_of(described_class).to receive(:calculate_line_44).and_return 1_000
      end
      it "subtracts line 39 from line 44" do
        instance.calculate
        expect(instance.lines[:MD502_LINE_46].value).to eq(100)
        expect(instance.lines[:MD502_LINE_48].value).to eq(100)
      end
    end

    context "line 39 is more than 44" do
      before do
        allow_any_instance_of(described_class).to receive(:calculate_line_39).and_return 150
        allow_any_instance_of(described_class).to receive(:calculate_line_44).and_return 50
      end
      it "returns nil" do
        instance.calculate
        expect(instance.lines[:MD502_LINE_46].value).to eq(nil)
      end
    end
  end

  describe "#calculate_line_30" do
    context "deduction method is standard and they qualify for state poverty level credit" do
      before do
        intake.direct_file_data.fed_wages_salaries_tips = 1001
        allow_any_instance_of(described_class).to receive(:calculate_deduction_method).and_return "S"
        allow_any_instance_of(described_class).to receive(:calculate_line_23).and_return 100
        instance.calculate
      end

      context "when county is Allegany" do
        it "multiplies line 22 by local tax rate" do
          # 1001 * 0303
          expect(instance.lines[:MD502_LINE_30].value).to eq 30
        end
      end

      context "when county is Anne Arundel" do
        let(:county) { "Anne Arundel" }
        it "multiplies line 22 by 0.0270" do
          # 1001 * .0270
          expect(instance.lines[:MD502_LINE_30].value).to eq 27
        end
      end
    end

    context "deduction method is non-standard" do
      it "returns nil" do
        allow_any_instance_of(described_class).to receive(:calculate_deduction_method).and_return "N"
        allow_any_instance_of(described_class).to receive(:calculate_line_23).and_return 100
        instance.calculate
        expect(instance.lines[:MD502_LINE_30].value).to eq nil
      end
    end

    context "they do not qualify for state poverty level credit" do
      it "returns nil" do
        allow_any_instance_of(described_class).to receive(:calculate_deduction_method).and_return "S"
        allow_any_instance_of(described_class).to receive(:calculate_line_23).and_return 0
        instance.calculate
        expect(instance.lines[:MD502_LINE_30].value).to eq nil
      end
    end
  end

  describe "#calculate_line_32" do
    context "deduction method is standard" do
      before do
        allow_any_instance_of(described_class).to receive(:calculate_deduction_method).and_return "S"
        allow_any_instance_of(described_class).to receive(:calculate_line_29).and_return 100
        allow_any_instance_of(described_class).to receive(:calculate_line_30).and_return 230
      end

      it "adds line 29 and 30" do
        instance.calculate
        expect(instance.lines[:MD502_LINE_32].value).to eq 330
      end
    end

    context "deduction method is non-standard" do
      it "returns nil" do
        allow_any_instance_of(described_class).to receive(:calculate_deduction_method).and_return "N"
        instance.calculate
        expect(instance.lines[:MD502_LINE_32].value).to eq nil
      end
    end
  end

  describe "#calculate_line_33" do
    context "deduction method is standard" do
      before do
        allow_any_instance_of(described_class).to receive(:calculate_deduction_method).and_return "S"
        allow_any_instance_of(described_class).to receive(:calculate_line_28_local_tax_amount).and_return 500
        allow_any_instance_of(described_class).to receive(:calculate_line_32).and_return 200
      end

      it "subtracts line 32 from line 28" do
        instance.calculate
        expect(instance.lines[:MD502_LINE_33].value).to eq 300
      end

      context "when local tax is negative" do
        before do
          allow_any_instance_of(described_class).to receive(:calculate_line_28_local_tax_amount).and_return 100
        end
        it "returns 0" do
          instance.calculate
          expect(instance.lines[:MD502_LINE_33].value).to eq 0
        end
      end
    end

    context "deduction method is non-standard" do
      it "returns nil" do
        allow_any_instance_of(described_class).to receive(:calculate_deduction_method).and_return "N"
        instance.calculate
        expect(instance.lines[:MD502_LINE_33].value).to eq nil
      end
    end
  end

  describe "#calculate_line_34" do
    context "deduction method is standard" do
      before do
        allow_any_instance_of(described_class).to receive(:calculate_deduction_method).and_return "S"
        allow_any_instance_of(described_class).to receive(:calculate_line_27).and_return 500
        allow_any_instance_of(described_class).to receive(:calculate_line_33).and_return 200
      end

      it "add lines 27 and 33" do
        instance.calculate
        expect(instance.lines[:MD502_LINE_34].value).to eq 700
      end
    end

    context "deduction method is non-standard" do
      it "returns nil" do
        allow_any_instance_of(described_class).to receive(:calculate_deduction_method).and_return "N"
        instance.calculate
        expect(instance.lines[:MD502_LINE_34].value).to eq nil
      end
    end
  end

  describe "refund_or_owed_amount" do
    it "subtracts owed amount from refund amount" do
      allow(instance).to receive(:calculate_line_48).and_return 0
      allow(instance).to receive(:calculate_line_50).and_return -30
      instance.calculate
      expect(instance.refund_or_owed_amount).to eq(30)
    end
  end

  describe "MD502_AUTHORIZE_DIRECT_DEPOSIT" do
    context "bank authorization was given" do
      it "should return true" do
        intake.bank_authorization_confirmed = 'yes'
        instance.calculate
        expect(instance.lines[:MD502_AUTHORIZE_DIRECT_DEPOSIT].value).to eq(true)
      end
    end

    context "bank authorization was not given" do
      it "should return false" do
        intake.bank_authorization_confirmed = 'unfilled'
        instance.calculate
        expect(instance.lines[:MD502_AUTHORIZE_DIRECT_DEPOSIT].value).to eq(false)
      end
    end

    context "bank authorization was 'no'" do
      it "should return false" do
        intake.bank_authorization_confirmed = 'no'
        instance.calculate
        expect(instance.lines[:MD502_AUTHORIZE_DIRECT_DEPOSIT].value).to eq(false)
      end
    end
  end
end
