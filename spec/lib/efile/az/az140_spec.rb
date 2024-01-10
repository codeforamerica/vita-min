require 'rails_helper'

describe Efile::Az::Az140 do
  let(:dependents) { [create(:state_file_dependent, dob: 7.years.ago)] }
  let(:intake) { create(:state_file_az_intake, eligibility_lived_in_state: 1, dependents: dependents) }
  let(:instance) do
    described_class.new(
      year: MultiTenantService.statefile.current_tax_year,
      intake: intake
    )
  end

  describe 'Line 56 Increased Excise Tax Credit' do
    context 'when the client does not have a valid SSN because it is not present' do
      before do
        intake.direct_file_data.primary_ssn = nil
        intake.direct_file_data.filing_status = 1 # single
        intake.direct_file_data.fed_agi = 12_500 # qualifying agi
        intake.was_incarcerated = 2 # no
      end

      it 'sets the amount to 0 because the client does not qualify' do
        instance.calculate
        expect(instance.lines[:AZ140_LINE_56].value).to eq(0)
      end
    end
  end

  context 'when the client does not have a valid SSN because it starts with 9' do
    before do
      intake.direct_file_data.primary_ssn = '999999999' # invalid
      intake.direct_file_data.filing_status = 1 # single
      intake.direct_file_data.fed_agi = 12_500 # qualifying agi
      intake.was_incarcerated = 2 # no
    end

    it 'sets the amount to 0 because the client does not qualify' do
      instance.calculate
      expect(instance.lines[:AZ140_LINE_56].value).to eq(0)
    end
  end

  context 'when the client has been claimed as a dependent' do
    before do
      intake.direct_file_data.primary_ssn = '555002222' # valid
      intake.direct_file_data.filing_status = 1 # single
      intake.direct_file_data.fed_agi = 12_500 # qualifying agi
      intake.direct_file_data.primary_claim_as_dependent = 'X'
      intake.was_incarcerated = 2 # no
    end

    it 'sets the amount to 0 because the client does not qualify' do
      instance.calculate
      expect(instance.lines[:AZ140_LINE_56].value).to eq(0)
    end
  end

  context 'when the client was incarcerated for more than 60 days' do
    before do
      intake.direct_file_data.primary_ssn = '555002222' # valid
      intake.direct_file_data.filing_status = 1 # single
      intake.direct_file_data.fed_agi = 12_500 # qualifying agi
      intake.was_incarcerated = 1 # yes
    end

    it 'sets the amount to 0 because the client does not qualify' do
      instance.calculate
      expect(instance.lines[:AZ140_LINE_56].value).to eq(0)
    end
  end

  context 'when the client has too much income and is filing single' do
    before do
      intake.direct_file_data.primary_ssn = '555002222' # valid
      intake.direct_file_data.filing_status = 1 # single
      intake.direct_file_data.fed_agi = 12_501 # disqualifying agi
      intake.was_incarcerated = 2 # no
    end

    it 'sets the amount to 0 because the client does not qualify' do
      instance.calculate
      expect(instance.lines[:AZ140_LINE_56].value).to eq(0)
    end
  end

  context 'when the client has too much income and is filing mfs' do
    before do
      intake.direct_file_data.primary_ssn = '555002222' # valid
      intake.direct_file_data.filing_status = 3 # mfs
      intake.direct_file_data.fed_agi = 12_501 # disqualifying agi
      intake.was_incarcerated = 2 # no
    end

    it 'sets the amount to 0 because the client does not qualify' do
      instance.calculate
      expect(instance.lines[:AZ140_LINE_56].value).to eq(0)
    end
  end

  context 'when the client has too much income and is filing mfj' do
    before do
      intake.direct_file_data.primary_ssn = '555002222' # valid
      intake.direct_file_data.filing_status = 2 # mfj
      intake.direct_file_data.fed_agi = 25_001 # disqualifying agi
      intake.was_incarcerated = 2 # no
    end

    it 'sets the amount to 0 because the client does not qualify' do
      instance.calculate
      expect(instance.lines[:AZ140_LINE_56].value).to eq(0)
    end
  end

  context 'when the client has too much income and is filing hoh' do
    before do
      intake.direct_file_data.primary_ssn = '555002222' # valid
      intake.direct_file_data.filing_status = 4 # hoh
      intake.direct_file_data.fed_agi = 25_001 # disqualifying agi
      intake.was_incarcerated = 2 # no
    end

    it 'sets the amount to 0 because the client does not qualify' do
      instance.calculate
      expect(instance.lines[:AZ140_LINE_56].value).to eq(0)
    end
  end

  context 'when the client qualifies for the credit and is filing single' do
    before do
      intake.direct_file_data.primary_ssn = '555002222' # valid
      intake.direct_file_data.filing_status = 1 # single
      intake.direct_file_data.fed_agi = 12_500 # qualifying agi
      intake.was_incarcerated = 2 # no
    end

    it 'sets the credit to the correct amount' do
      instance.calculate
      expect(instance.lines[:AZ140_LINE_56].value).to eq(50) # (1 filer + 1 dependent) * 25
    end
  end

  context 'when the client qualifies for the credit and is filing mfs' do
    before do
      intake.direct_file_data.primary_ssn = '555002222' # valid
      intake.direct_file_data.filing_status = 3 # mfs
      intake.direct_file_data.fed_agi = 12_500 # qualifying agi
      intake.was_incarcerated = 2 # no
    end

    it 'sets the credit to the correct amount' do
      instance.calculate
      expect(instance.lines[:AZ140_LINE_56].value).to eq(50) # (1 filer + 1 dependent) * 25
    end
  end

  context 'when the client qualifies for the credit and is filing mfj' do
    before do
      intake.direct_file_data.primary_ssn = '555002222' # valid
      intake.direct_file_data.filing_status = 2 # mfj
      intake.direct_file_data.fed_agi = 25_000 # qualifying agi
      intake.was_incarcerated = 2 # no
    end

    it 'sets the credit to the correct amount' do
      instance.calculate
      expect(instance.lines[:AZ140_LINE_56].value).to eq(75) # (2 filers + 1 dependent) * 25
    end
  end

  context 'when the client qualifies for the credit and is filing hoh' do
    before do
      intake.direct_file_data.primary_ssn = '555002222' # valid
      intake.direct_file_data.filing_status = 4 # hoh
      intake.direct_file_data.fed_agi = 25_000 # # qualifying agi
      intake.was_incarcerated = 2 # no
    end

    it 'sets the credit to the correct amount' do
      instance.calculate
      expect(instance.lines[:AZ140_LINE_56].value).to eq(50) # (1 filer + 1 dependent) * 25
    end
  end

  context 'when the client qualifies for the maximum credit' do
    before do
      intake.direct_file_data.primary_ssn = '555002222' # valid
      intake.direct_file_data.filing_status = 1 # single
      intake.direct_file_data.fed_agi = 12_500 # qualifying agi
      intake.was_incarcerated = 2 # no
      intake.dependents.create(dob: 5.years.ago)
      intake.dependents.create(dob: 3.years.ago)
      intake.dependents.create(dob: 1.years.ago)
    end

    it 'sets the credit to the maximum amount' do
      instance.calculate
      expect(instance.lines[:AZ140_LINE_56].value).to eq(100) # (1 filer + 4 dependents) * 25 = 125 but max is 100
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

end