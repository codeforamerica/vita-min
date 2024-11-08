require 'rails_helper'

describe Efile::Az::Az140Calculator do
  let(:intake) { create(:state_file_az_intake, eligibility_lived_in_state: 1) }
  let(:instance) do
    described_class.new(
      year: MultiTenantService.statefile.current_tax_year,
      intake: intake
    )
  end

  context "when claiming multiple dependents of different classifications" do
    let(:intake) { create(:state_file_az_johnny_intake) }

    it "counts the dependents correctly by their classifications" do
      instance.calculate
      expect(instance.lines[:AZ140_LINE_10A].value).to eq(4)
      expect(instance.lines[:AZ140_LINE_10B].value).to eq(3)
      expect(instance.lines[:AZ140_LINE_11A].value).to eq(1)
    end
  end

  context 'sets line 7c correctly' do
    before do
      intake.charitable_cash_amount = 50
      intake.charitable_noncash_amount = 50
      intake.charitable_contributions = 'yes'
      allow(instance).to receive(:calculate_line_42).and_return 10_000
      allow(instance).to receive(:calculate_line_43).and_return 2_000
    end

    # 31% of 100 (50+50)
    it 'sets the credit to the maximum amount' do
      instance.calculate
      expect(instance.lines[:AZ140_CCWS_LINE_7c].value).to eq(31)
      expect(instance.lines[:AZ140_LINE_44].value).to eq(31)
      expect(instance.lines[:AZ140_LINE_45].value).to eq(7_969)
    end
  end

  describe "Line 8" do
    let(:senior_cutoff_date) { Date.new((MultiTenantService.statefile.current_tax_year - 70), 12, 31) }

    context "when both primary and spouse are older than 65" do
      let(:intake) { create(:state_file_az_intake, :with_senior_spouse, primary_birth_date: senior_cutoff_date, spouse_birth_date: senior_cutoff_date) }

      it "returns 2" do
        instance.calculate
        expect(instance.lines[:AZ140_LINE_8].value).to eq(2)
      end
    end

    context "when only the primary is over 65" do
      let(:intake) { create(:state_file_az_intake, :with_spouse, primary_birth_date: senior_cutoff_date) }

      it "returns 1" do
        instance.calculate
        expect(instance.lines[:AZ140_LINE_8].value).to eq(1)
      end
    end

    context "when born a day after the senior cutoff date" do
      let(:intake) { create(:state_file_az_intake, :with_senior_spouse, primary_birth_date: senior_cutoff_date + 1.day, spouse_birth_date: senior_cutoff_date) }

      it "it counts them" do
        instance.calculate
        expect(instance.lines[:AZ140_LINE_8].value).to eq(2)
      end
    end
  end

  describe "Line 28" do
    context "has no interest reports with interest on government bonds" do
      it "returns 0" do
        instance.calculate
        expect(instance.lines[:AZ140_LINE_28].value).to eq(0)
      end
    end

    context "has interest reports with interest on government bonds" do
      let(:intake) { create(:state_file_az_intake, :df_data_1099_int) }

      it "returns sum of the interest on government bonds" do
        instance.calculate
        expect(instance.lines[:AZ140_LINE_28].value).to eq(2)
      end
    end
  end

  describe "Line 43 and 43S: standard deduction" do
    let(:intake) { create(:state_file_az_intake, filing_status: filing_status) }

    context "single" do
      let(:filing_status) { "single" }

      it "sets the standard deduction correctly" do
        instance.calculate
        expect(instance.lines[:AZ140_LINE_43].value).to eq(13_850)
        expect(instance.lines[:AZ140_LINE_43S].value).to eq('Standard')
      end
    end

    context "mfj" do
      let(:filing_status) { "married_filing_jointly" }

      it "sets the standard deduction correctly" do
        instance.calculate
        expect(instance.lines[:AZ140_LINE_43].value).to eq(27_700)
        expect(instance.lines[:AZ140_LINE_43S].value).to eq('Standard')
      end
    end

    context "hoh" do
      context "actually hoh" do
        let(:filing_status) { "head_of_household" }

        it "sets the standard deduction correctly" do
          instance.calculate
          expect(instance.lines[:AZ140_LINE_43].value).to eq(20_800)
          expect(instance.lines[:AZ140_LINE_43S].value).to eq('Standard')
        end
      end

      context "actually qss" do
        let(:filing_status) { "qualifying_widow" }

        it "sets the standard deduction to the same amount as hoh" do
          instance.calculate
          expect(instance.lines[:AZ140_LINE_43].value).to eq(20_800)
          expect(instance.lines[:AZ140_LINE_43S].value).to eq('Standard')
        end
      end
    end
  end

  describe "Line 45: Arizona taxable income" do
    context "line 42 - (line 43 + 44) is more than 0" do
      it "enters the amount" do
        allow(instance).to receive(:calculate_line_42).and_return 3_000
        allow(instance).to receive(:calculate_line_43).and_return 1_000
        allow(instance).to receive(:calculate_line_44).and_return 1_000

        instance.calculate
        expect(instance.lines[:AZ140_LINE_45].value).to eq(1_000)
      end
    end

    context "line 42 - (line 43 + 44) is less than 0" do
      it "enters 0" do
        allow(instance).to receive(:calculate_line_42).and_return 1_000
        allow(instance).to receive(:calculate_line_43).and_return 1_000
        allow(instance).to receive(:calculate_line_44).and_return 1_000

        instance.calculate
        expect(instance.lines[:AZ140_LINE_45].value).to eq(0)
      end
    end
  end

  describe "Line 46: tax" do
    it "multiplies line 45 by 0.025" do
      allow(instance).to receive(:calculate_line_45).and_return 20_000

      instance.calculate
      expect(instance.lines[:AZ140_LINE_46].value).to eq(500)
    end

    it "rounds the result" do
      allow(instance).to receive(:calculate_line_45).and_return 20_500

      instance.calculate
      expect(instance.lines[:AZ140_LINE_46].value).to eq(513)
    end
  end

  describe 'Line 53: AZ Income Tax Withheld' do
    let(:intake) {
      # alexis has $500 state tax withheld on a w2 & $10 state tax withheld on a 1099r
      create(:state_file_az_intake,
             :with_1099_rs_synced,
             :with_w2s_synced,
             raw_direct_file_data: StateFile::DirectFileApiResponseSampleService.new.read_xml('az_alexis_hoh_w2_and_1099'))
    }
    let!(:state_file1099_g) { create(:state_file1099_g, intake: intake, state_income_tax_withheld_amount: 100) }

    it 'sums the AZ tax withheld from w2s, 1099gs and 1099rs' do
      instance.calculate
      expect(instance.lines[:AZ140_LINE_53].value).to eq(610)
    end
  end

  describe "Line 56: Increased Excise Tax Credit" do
    before do
      allow(intake).to receive(:disqualified_from_excise_credit_fyst?).and_return false
    end

    context "when the client is disqualified because of the answers they gave during intake" do
      it "sets the amount to 0" do
        allow(intake).to receive(:disqualified_from_excise_credit_fyst?).and_return true
        instance.calculate
        expect(instance.lines[:AZ140_LINE_56].value).to eq(0)
      end
    end

    context "when the client is disqualified for having too much income" do
      context "fed agi above 12,501" do
        before do
          intake.direct_file_data.fed_agi = 12_501
        end

        it "when single sets the amount to 0" do
          intake.direct_file_data.filing_status = 1 # single
          instance.calculate
          expect(instance.lines[:AZ140_LINE_56].value).to eq(0)
        end

        it "when mfs sets the amount to 0" do
          intake.direct_file_data.filing_status = 3 # mfs
          instance.calculate
          expect(instance.lines[:AZ140_LINE_56].value).to eq(0)
        end
      end

      context "fed agi above 25,001" do
        before do
          intake.direct_file_data.fed_agi = 25_001
        end

        it "when mfj sets the amount to 0" do
          intake.direct_file_data.filing_status = 2 # mfj
          instance.calculate
          expect(instance.lines[:AZ140_LINE_56].value).to eq(0)
        end

        it "when hoh sets the amount to 0" do
          intake.direct_file_data.filing_status = 4 # hoh
          instance.calculate
          expect(instance.lines[:AZ140_LINE_56].value).to eq(0)
        end
      end
    end

    context "single filer with one dependent" do
      it "sets the credit to the correct amount" do
        intake.dependents.create(dob: 7.years.ago)
        intake.direct_file_data.filing_status = 1 # single
        intake.direct_file_data.fed_agi = 12_500 # qualifying agi

        instance.calculate
        expect(instance.lines[:AZ140_LINE_56].value).to eq(50) # (1 filer + 1 dependent) * 25
      end
    end

    context "mfs filer with one dependent" do
      it "sets the credit to the correct amount" do
        intake.dependents.create(dob: 7.years.ago)
        intake.direct_file_data.filing_status = 3 # mfs
        intake.direct_file_data.fed_agi = 12_500 # qualifying agi

        instance.calculate
        expect(instance.lines[:AZ140_LINE_56].value).to eq(50) # (1 filer + 1 dependent) * 25
      end
    end

    context "mfj filer with one dependent" do
      it "sets the credit to the correct amount" do
        intake.dependents.create(dob: 7.years.ago)
        intake.direct_file_data.filing_status = 2 # mfj
        intake.direct_file_data.fed_agi = 25_000 # qualifying agi

        instance.calculate
        expect(instance.lines[:AZ140_LINE_56].value).to eq(75) # (2 filers + 1 dependent) * 25
      end
    end

    context "hoh filer with one dependent" do
      it "sets the credit to the correct amount" do
        intake.dependents.create(dob: 7.years.ago)
        intake.direct_file_data.filing_status = 4 # hoh
        intake.direct_file_data.fed_agi = 25_000 # # qualifying agi
        instance.calculate
        expect(instance.lines[:AZ140_LINE_56].value).to eq(50) # (1 filer + 1 dependent) * 25
      end
    end

    context "when the client qualifies for the maximum credit" do
      it "sets the credit to the maximum amount" do
        intake.direct_file_data.filing_status = 1 # single
        intake.direct_file_data.fed_agi = 12_500 # qualifying agi
        intake.dependents.create(dob: 7.years.ago)
        intake.dependents.create(dob: 5.years.ago)
        intake.dependents.create(dob: 3.years.ago)
        intake.dependents.create(dob: 1.years.ago)
        instance.calculate
        expect(instance.lines[:AZ140_LINE_56].value).to eq(100) # (1 filer + 4 dependents) * 25 = 125 but max is 100
      end
    end

    context "mfj filer, one incarcerated, no dependents" do
      it "calculates the credit without incarcerated filer" do
        intake.direct_file_data.filing_status = 2 # mfj
        intake.direct_file_data.fed_agi = 12_500 # qualifying agi
        intake.update(primary_was_incarcerated: "no", spouse_was_incarcerated: "yes")
        instance.calculate
        expect(instance.lines[:AZ140_LINE_56].value).to eq(25) # (1 filer) * 25 = 25
      end

      it "handles the old column for now" do
        intake.direct_file_data.filing_status = 2 # mfj
        intake.direct_file_data.fed_agi = 12_500 # qualifying agi
        intake.update(was_incarcerated: "no")
        instance.calculate
        expect(instance.lines[:AZ140_LINE_56].value).to eq(50) # (2 filers) * 25 = 25
      end
    end

    context "single filer with four dependents with some credit already claimed" do
      it "adjusts the max credit" do
        intake.direct_file_data.filing_status = 1 # single
        intake.direct_file_data.fed_agi = 12_500 # qualifying agi
        intake.dependents.create(dob: 7.years.ago)
        intake.dependents.create(dob: 5.years.ago)
        intake.dependents.create(dob: 3.years.ago)
        intake.dependents.create(dob: 1.years.ago)
        intake.update(household_excise_credit_claimed: "yes", household_excise_credit_claimed_amount: 40)
        instance.calculate
        expect(instance.lines[:AZ140_LINE_56].value).to eq(60) # (1 filer + 4 dependents) * 25 = 125 but max is 60
      end
    end

    # TODO: [JH] i don't....understand this test? was copied from commit a674f6f
    context "filing status is qualifying widow" do
      it "sets the family income tax credit and excise credit to 0" do
        intake.direct_file_data.filing_status = 5 # qualifying_widow
        instance.calculate
        expect(instance.lines[:AZ140_LINE_50].value).to eq(0)
        expect(instance.lines[:AZ140_LINE_56].value).to eq(0)
      end
    end
  end
end