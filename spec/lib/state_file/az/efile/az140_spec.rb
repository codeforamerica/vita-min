require 'rails_helper'

describe StateFile::Az::Efile::Az140 do
  let(:intake) { create(:state_file_az_intake, eligibility_lived_in_state: 1) }
  let(:instance) do
    described_class.new(
      year: MultiTenantService.statefile.current_tax_year,
      intake: intake
    )
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
        intake.update(household_excise_credit_claimed: "yes", household_excise_credit_claimed_amt: 40)
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

  context 'sets line 7c correctly' do
    before do
      intake.charitable_cash = 50
      intake.charitable_noncash = 50
      intake.charitable_contributions = 'yes'
    end

    # 31% of 100 (50+50)
    it 'sets the credit to the maximum amount' do
      instance.calculate
      expect(instance.lines[:AZ140_CCWS_LINE_7c].value).to eq(31)
      expect(instance.lines[:AZ140_LINE_44].value).to eq(31)
      expect(instance.lines[:AZ140_LINE_45].value).to eq(98392) # Charitable contribitions affect this; before was 98423
    end
  end

  describe 'the Az flat tax rate is 2.5%' do
    context 'when the filer has an income of $25,000' do
      before do
        intake.direct_file_data.fed_agi = 25_000
      end
      it 'the tax is 2.5%' do
        instance.calculate
        expect(instance.lines[:AZ140_LINE_45].value).to eq(3423) # Deductions mean this is taxable
        expect(instance.lines[:AZ140_LINE_46].value).to eq(86)
      end
    end
    context 'when the filer has an income of $150,000' do
      before do
        intake.direct_file_data.fed_agi = 150_000
      end
      it 'the tax is 2.5%' do
        instance.calculate
        expect(instance.lines[:AZ140_LINE_45].value).to eq(128423) # Deductions mean this is taxable
        expect(instance.lines[:AZ140_LINE_46].value).to eq(3211)
      end
    end
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

  # Check for filing status lines 4-7
  describe '#filing_status' do
    context 'when is single' do
      let(:intake) { create(:state_file_az_intake) }
      before do
        intake.direct_file_data.filing_status = 1 # single
      end

      it 'sets filing_status to single' do
        instance.calculate
        expect(intake.filing_status).to eq(:single)
      end
    end

    context 'when filing_status is qualifying_widow / QSS' do
      let(:intake) { create(:state_file_az_intake) }
      before do
        intake.direct_file_data.filing_status = 5 # qualifying_widow
      end

      it 'sets filing_status to hoh' do
        instance.calculate
        expect(intake.filing_status).to eq(:head_of_household)
      end
    end
  end

  # Check for standard deduction line 43
  describe 'Standard deductions' do
    let(:intake) { create(:state_file_az_intake) }
    before do
      intake.direct_file_data.filing_status = 5 # qualifying_widow
    end

    it 'sets the standard deduction correctly for QSS' do
      instance.calculate
      expect(instance.lines[:AZ140_LINE_43].value).to eq(20_800)
      expect(instance.lines[:AZ140_LINE_43S].value).to eq('Standard')
    end
  end
end