require 'rails_helper'

describe Efile::Ny::It201 do
  let(:intake) { create(:state_file_ny_intake) }
  let!(:dependent) { intake.dependents.create(dob: 7.years.ago) }
  let(:instance) do
    described_class.new(
      year: MultiTenantService.statefile.current_tax_year,
      intake: intake
    )
  end

  describe '#calculate_line_17' do
    it "adds up some of the prior lines" do
      expect(instance.calculate[:IT201_LINE_17]).to eq(35_151)
    end
  end

  describe 'Line 33 New York State tax from tables' do
    context 'when there are NY additions (lines 20-24) and subtractions (lines 25-31)' do
      it 'populates the correct value for the New York adjusted gross income' do
        instance.calculate
        expect(instance.lines[:IT201_LINE_24].value).to eq(32_351)
        expect(instance.lines[:IT201_LINE_32].value).to eq(5_627)
        expect(instance.lines[:IT201_LINE_33].value).to eq(26_724) # (subtract line 32 from line 24)
      end
    end
  end

  describe 'Lines 34-38 New York State tax from tables' do
    context 'IT201_LINE_34' do
      context 'when the filing status is single AND primary_claim_as_dependent' do
        before do
          intake.direct_file_data.filing_status = 1 # single
          intake.direct_file_data.primary_claim_as_dependent = 'X'
        end

        it 'sets the correct deduction amount' do
          instance.calculate
          expect(instance.lines[:IT201_LINE_34].value).to eq(3_100)
        end
      end

      context 'when the filing status is single' do
        before do
          intake.direct_file_data.filing_status = 1 # single
        end

        it 'sets the correct deduction amount' do
          instance.calculate
          expect(instance.lines[:IT201_LINE_34].value).to eq(8_000)
        end
      end

      context 'when the filing status is married_filing_separately' do
        before do
          intake.direct_file_data.filing_status = 3 # married_filing_separately
        end

        it 'sets the correct deduction amount' do
          instance.calculate
          expect(instance.lines[:IT201_LINE_34].value).to eq(8_000)
        end
      end

      context 'when the filing status is married_filing_jointly' do
        before do
          intake.direct_file_data.filing_status = 2 # married_filing_jointly
        end

        it 'sets the correct deduction amount' do
          instance.calculate
          expect(instance.lines[:IT201_LINE_34].value).to eq(16_050)
        end
      end

      context 'when the filing status is qualifying_widow' do
        before do
          intake.direct_file_data.filing_status = 5 # qualifying_widow
        end

        it 'sets the correct deduction amount' do
          instance.calculate
          expect(instance.lines[:IT201_LINE_34].value).to eq(16_050)
        end
      end

      context 'when the filing status is head_of_household' do
        before do
          intake.direct_file_data.filing_status = 4 # head_of_household
        end

        it 'sets the correct deduction amount' do
          instance.calculate
          expect(instance.lines[:IT201_LINE_34].value).to eq(11_200)
        end
      end
    end

    context 'IT201_LINE_35' do
      context 'when line33 > line34' do
        it 'populates the correct value to line35' do
          instance.calculate
          expect(instance.lines[:IT201_LINE_33].value).to eq(26_724)
          expect(instance.lines[:IT201_LINE_34].value).to eq(8_000)
          expect(instance.lines[:IT201_LINE_35].value).to eq(18_724) # (Subtract line 34 from line 33)
        end
      end

      context 'when line34 > line33' do
        before do
          allow(instance).to receive(:calculate_line_33).and_return(7000)
        end

        it 'leaves line35 blank' do
          instance.calculate
          expect(instance.lines[:IT201_LINE_33].value).to eq(7000)
          expect(instance.lines[:IT201_LINE_34].value).to eq(8000)
          expect(instance.lines[:IT201_LINE_35].value).to eq(0) # (if line 34 is more than line 33, leave blank)
        end
      end
    end

    context 'IT201_LINE_36' do
      it 'adds the correct dependent exemptions' do
        instance.calculate
        expect(intake.dependents.count).to eq(1)
        expect(instance.lines[:IT201_LINE_36].value).to eq(1) # (The form adds a '000.00' to it == 1000.00)
      end
    end

    context 'IT201_LINE_37' do
      it 'adds the correct taxable income' do
        instance.calculate
        expect(instance.lines[:IT201_LINE_35].value).to eq(18_724)
        expect(instance.lines[:IT201_LINE_36].value).to eq(1)
        # Taxable income (subtract line 36*1000 from line 35)
        # 18_724 - 1000
        expect(instance.lines[:IT201_LINE_37].value).to eq(17_724)
      end
    end

    context 'IT201_LINE_38' do
      it 'sets the correct taxable income' do
        instance.calculate
        expect(instance.lines[:IT201_LINE_37].value).to eq(17_724)
        expect(instance.lines[:IT201_LINE_38].value).to eq(17_724) # Taxable income (from line 37 on page 2)
      end
    end
  end

  describe '#calculate_line_39' do
    context 'when single with 58k agi' do
      before do
        intake.direct_file_data.filing_status = 1 # single
        allow(instance).to receive(:line_or_zero).and_call_original
        allow(instance).to receive(:line_or_zero).with(:IT201_LINE_33).and_return(58_000)
        allow(instance).to receive(:line_or_zero).with(:IT201_LINE_38).and_return(50_000)
      end

      it 'sets the correct tax amount' do
        instance.calculate
        expect(instance.lines[:IT201_LINE_39].value).to eq(2_586)
      end
    end

    context 'when mfj with 136,050 agi' do
      before do
        intake.direct_file_data.filing_status = 2 # mfj
        allow(instance).to receive(:line_or_zero).and_call_original
        allow(instance).to receive(:line_or_zero).with(:IT201_LINE_33).and_return(136_050)
        allow(instance).to receive(:line_or_zero).with(:IT201_LINE_38).and_return(120_000)
      end

      it 'sets the correct tax amount' do
        instance.calculate
        expect(instance.lines[:IT201_LINE_39].value).to eq(6_456)
      end
    end

    context 'when mfs with 168k agi' do
      before do
        intake.direct_file_data.filing_status = 3 # mfs
        allow(instance).to receive(:line_or_zero).and_call_original
        allow(instance).to receive(:line_or_zero).with(:IT201_LINE_33).and_return(168_000)
        allow(instance).to receive(:line_or_zero).with(:IT201_LINE_38).and_return(160_000)
      end

      it 'sets the correct tax amount' do
        instance.calculate
        expect(instance.lines[:IT201_LINE_39].value).to eq(9_600)
      end
    end

    context 'when hoh with 24.2k agi' do
      before do
        intake.direct_file_data.filing_status = 4 # hoh
        allow(instance).to receive(:line_or_zero).and_call_original
        allow(instance).to receive(:line_or_zero).with(:IT201_LINE_33).and_return(24_200)
        allow(instance).to receive(:line_or_zero).with(:IT201_LINE_38).and_return(11_000)
      end

      it 'sets the correct tax amount' do
        instance.calculate
        expect(instance.lines[:IT201_LINE_39].value).to eq(440)
      end
    end

    context 'when qss with 44,950 agi' do
      before do
        intake.direct_file_data.filing_status = 5 # qss
        allow(instance).to receive(:line_or_zero).and_call_original
        allow(instance).to receive(:line_or_zero).with(:IT201_LINE_33).and_return(44_950)
        allow(instance).to receive(:line_or_zero).with(:IT201_LINE_38).and_return(27_900)
      end

      it 'sets the correct tax amount' do
        instance.calculate
        expect(instance.lines[:IT201_LINE_39].value).to eq(1_202)
      end
    end
  end

  describe '#calculate_line_40 Line 40 NYS household credit' do
    context 'when the filer has been claimed as a dependent' do
      before do
        intake.direct_file_data.primary_claim_as_dependent = "X"
        intake.direct_file_data.fed_wages = 2_000
        intake.direct_file_data.fed_taxable_income = 2_000
        intake.direct_file_data.fed_taxable_ssb = 0
        intake.direct_file_data.fed_unemployment = 0
      end

      it 'sets the credit to 0 because the filer is ineligible' do
        instance.calculate
        expect(instance.lines[:IT201_LINE_40].value).to eq(0)
      end
    end

    context 'when filing status is single' do
      before do
        intake.direct_file_data.filing_status = 1 # single
        intake.direct_file_data.fed_wages = 2_000
        intake.direct_file_data.fed_taxable_income = 2_000
        intake.direct_file_data.fed_taxable_ssb = 0
        intake.direct_file_data.fed_unemployment = 0
      end

      it 'uses the correct table to set the value of the credit' do
        instance.calculate
        expect(instance.lines[:IT201_LINE_19].value).to eq(1_200)
        expect(instance.lines[:IT201_LINE_40].value).to eq(75)
      end
    end

    context 'when filing status is married filing separately' do
      before do
        intake.direct_file_data.filing_status = 3 # mfs
        intake.direct_file_data.fed_wages = 2_000
        intake.direct_file_data.fed_taxable_income = 2_000
        intake.direct_file_data.fed_taxable_ssb = 0
        intake.direct_file_data.fed_unemployment = 0
      end

      it 'uses the correct table to set the value of the credit' do
        instance.calculate
        expect(instance.lines[:IT201_LINE_19].value).to eq(1_200)
        expect(instance.lines[:IT201_LINE_40].value).to eq(60)
      end
    end

    context 'when filing status is married filing jointly' do
      before do
        intake.direct_file_data.filing_status = 2 # mfj
      end

      context "income under 5000" do
        before do
          intake.direct_file_data.fed_wages = 2_000
          intake.direct_file_data.fed_taxable_income = 2_000
          intake.direct_file_data.fed_taxable_ssb = 0
          intake.direct_file_data.fed_unemployment = 0
        end

        it 'uses the correct table to set the value of the credit' do
          instance.calculate
          expect(instance.lines[:IT201_LINE_19].value).to eq(1_200)
          expect(instance.lines[:IT201_LINE_40].value).to eq(120)
        end
      end

      context "income between 20k and 22k and 2 dependents" do
        before do
          intake.dependents.create!(dob: 7.years.ago)
          intake.direct_file_data.fed_wages = 21_000
          intake.direct_file_data.fed_total_adjustments = 0
          intake.direct_file_data.fed_taxable_income = 0
          intake.direct_file_data.fed_taxable_ssb = 0
          intake.direct_file_data.fed_unemployment = 0
        end

        it 'uses the correct table to set the value of the credit' do
          instance.calculate
          expect(instance.lines[:IT201_LINE_19].value).to eq(21_000)
          expect(instance.lines[:IT201_LINE_40].value).to eq(90)
        end
      end
    end
  end

  describe "#calculate_line_43" do
    it "is equal to line 40 because we are not supporting lines 41 and 42" do
      instance.calculate
      expect(instance.lines[:IT201_LINE_43].value).to eq instance.lines[:IT201_LINE_40].value
    end
  end

  describe "#calculate_line_44" do
    context "line 43 is less than line 39" do
      before do
        allow(instance).to receive(:calculate_line_43).and_return 50
        allow(instance).to receive(:calculate_line_39).and_return 100
      end

      it "is the difference between lines 39 and 43" do
        instance.calculate
        expect(instance.lines[:IT201_LINE_44].value).to eq 50
      end
    end

    context "line 43 is greater than line 39" do
      before do
        allow(instance).to receive(:calculate_line_43).and_return 100
        allow(instance).to receive(:calculate_line_39).and_return 50
      end

      it "is zero" do
        instance.calculate
        expect(instance.lines[:IT201_LINE_44].value).to eq 0
      end
    end
  end

  describe "#calculate_line_46" do
    it "is equal to line 44 because we are not supporting line 45" do
      instance.calculate
      expect(instance.lines[:IT201_LINE_46].value).to eq instance.lines[:IT201_LINE_44].value
    end
  end

  describe 'Line 48 NYC household credit' do
    context 'when the filer has been claimed as a dependent' do
      before do
        intake.direct_file_data.primary_claim_as_dependent = "X"
        intake.direct_file_data.fed_wages = 2_000
        intake.direct_file_data.fed_taxable_income = 2_000
        intake.direct_file_data.fed_taxable_ssb = 0
        intake.direct_file_data.fed_unemployment = 0
        intake.nyc_residency = "full_year" # yes
      end

      it 'sets the credit to 0 because the filer is ineligible' do
        instance.calculate
        expect(instance.lines[:IT201_LINE_48].value).to eq(0)
      end
    end

    context 'when the filer was not a full year NYC resident' do
      before do
        intake.nyc_residency = "none"
      end

      it 'sets the credit to 0 because the filer is ineligible' do
        instance.calculate
        expect(instance.lines[:IT201_LINE_48].value).to eq(0)
      end
    end

    context 'when filing status is single' do
      before do
        intake.direct_file_data.filing_status = 1 # single
        intake.direct_file_data.fed_wages = 2_000
        intake.direct_file_data.fed_taxable_income = 2_000
        intake.direct_file_data.fed_taxable_ssb = 0
        intake.direct_file_data.fed_unemployment = 0
      end

      it 'uses the correct table to set the value of the credit' do
        instance.calculate
        expect(instance.lines[:IT201_LINE_19].value).to eq(1_200)
        expect(instance.lines[:IT201_LINE_48].value).to eq(15)
      end
    end

    context 'when filing status is married filing separately' do
      before do
        intake.direct_file_data.filing_status = 3 # mfs
        intake.direct_file_data.fed_wages = 2_000
        intake.direct_file_data.fed_taxable_income = 2_000
        intake.direct_file_data.fed_taxable_ssb = 0
        intake.direct_file_data.fed_unemployment = 0
      end

      it 'uses the correct table to set the value of the credit' do
        instance.calculate
        expect(instance.lines[:IT201_LINE_19].value).to eq(1_200)
        expect(instance.lines[:IT201_LINE_48].value).to eq(45)
      end
    end

    context 'when filing status is married filing jointly' do
      before do
        intake.direct_file_data.filing_status = 2 # mfj
        intake.direct_file_data.fed_wages = 2_000
        intake.direct_file_data.fed_taxable_income = 2_000
        intake.direct_file_data.fed_taxable_ssb = 0
        intake.direct_file_data.fed_unemployment = 0
      end

      it 'uses the correct table to set the value of the credit' do
        instance.calculate
        expect(instance.lines[:IT201_LINE_19].value).to eq(1_200)
        expect(instance.lines[:IT201_LINE_48].value).to eq(90)
      end
    end
  end

  describe "#calculate_line_61" do
    before do
      intake.update(sales_use_tax: 50) # line 59 value
    end

    it "adds up some of the prior lines" do
      instance.calculate
      sum = instance.lines[:IT201_LINE_46].value + instance.lines[:IT201_LINE_58].value + instance.lines[:IT201_LINE_59].value
      expect(instance.lines[:IT201_LINE_61].value).to eq(sum)
    end
  end

  describe "#calculate_line_62" do
    it "is the same as line 61" do
      instance.calculate
      expect(instance.lines[:IT201_LINE_62].value).to eq instance.lines[:IT201_LINE_62].value
    end
  end

  describe 'Line 69 NYC school tax credit' do
    context 'when the filer has been claimed as a dependent' do
      before do
        intake.direct_file_data.primary_claim_as_dependent = "X"
        intake.nyc_residency = "full_year" # yes
        intake.direct_file_data.fed_wages = 2_000
        intake.direct_file_data.fed_taxable_income = 2_000
        intake.direct_file_data.fed_taxable_ssb = 0
        intake.direct_file_data.fed_unemployment = 0
      end

      it 'sets the credit to 0 because the filer is ineligible' do
        instance.calculate
        expect(instance.lines[:IT201_LINE_69].value).to eq(0)
      end
    end

    context 'when the filer was not a full year NYC resident' do
      before do
        intake.nyc_residency = "none" # no
        intake.direct_file_data.fed_wages = 2_000
        intake.direct_file_data.fed_taxable_income = 2_000
        intake.direct_file_data.fed_taxable_ssb = 0
        intake.direct_file_data.fed_unemployment = 0
      end

      it 'sets the credit to 0 because the filer is ineligible' do
        instance.calculate
        expect(instance.lines[:IT201_LINE_69].value).to eq(0)
      end
    end

    context 'when the filer had more than $250,000 in income' do
      before do
        intake.nyc_residency = "full_year" # yes
        intake.direct_file_data.fed_wages = 200_000
        intake.direct_file_data.fed_taxable_income = 200_000
        intake.direct_file_data.fed_taxable_ssb = 0
        intake.direct_file_data.fed_unemployment = 0
      end

      it 'sets the credit to 0 because the filer is ineligible' do
        instance.calculate
        expect(instance.lines[:IT201_LINE_69].value).to eq(0)
      end
    end

    context 'when the filer is eligible and filing status is single' do
      before do
        intake.direct_file_data.filing_status = 1 # single
        intake.nyc_residency = "full_year" # yes
        intake.direct_file_data.fed_wages = 2_000
        intake.direct_file_data.fed_taxable_income = 2_000
        intake.direct_file_data.fed_taxable_ssb = 0
        intake.direct_file_data.fed_unemployment = 0
      end

      it 'sets the credit to the proper value' do
        instance.calculate
        expect(instance.lines[:IT201_LINE_69].value).to eq(63)
      end
    end

    context 'when the filer is eligible and filing status is mfj' do
      before do
        intake.direct_file_data.filing_status = 2 # mfj
        intake.nyc_residency = "full_year" # yes
        intake.direct_file_data.fed_wages = 2_000
        intake.direct_file_data.fed_taxable_income = 2_000
        intake.direct_file_data.fed_taxable_ssb = 0
        intake.direct_file_data.fed_unemployment = 0
      end

      it 'sets the credit to the proper value' do
        instance.calculate
        expect(instance.lines[:IT201_LINE_69].value).to eq(125)
      end
    end

    context 'when the filer is eligible and filing status is mfs' do
      before do
        intake.direct_file_data.filing_status = 3 # mfs
        intake.nyc_residency = "full_year" # yes
        intake.direct_file_data.fed_wages = 2_000
        intake.direct_file_data.fed_taxable_income = 2_000
        intake.direct_file_data.fed_taxable_ssb = 0
        intake.direct_file_data.fed_unemployment = 0
      end

      it 'sets the credit to the proper value' do
        instance.calculate
        expect(instance.lines[:IT201_LINE_69].value).to eq(63)
      end
    end

    context 'when the filer is eligible and filing status is hoh' do
      before do
        intake.direct_file_data.filing_status = 4 # hoh
        intake.nyc_residency = "full_year" # yes
        intake.direct_file_data.fed_wages = 2_000
        intake.direct_file_data.fed_taxable_income = 2_000
        intake.direct_file_data.fed_taxable_ssb = 0
        intake.direct_file_data.fed_unemployment = 0
      end

      it 'sets the credit to the proper value' do
        instance.calculate
        expect(instance.lines[:IT201_LINE_69].value).to eq(63)
      end
    end

    context 'when the filer is eligible and filing status is qualifying_widow' do
      before do
        intake.direct_file_data.filing_status = 5 # qualifying_widow
        intake.nyc_residency = "full_year" # yes
        intake.direct_file_data.fed_wages = 2_000
        intake.direct_file_data.fed_taxable_income = 2_000
        intake.direct_file_data.fed_taxable_ssb = 0
        intake.direct_file_data.fed_unemployment = 0
      end

      it 'sets the credit to the proper value' do
        instance.calculate
        expect(instance.lines[:IT201_LINE_69].value).to eq(125)
      end
    end
  end

  describe '#calculate_it213' do
    context "with a bunch of eligible dependents" do
      let(:intake) { create(:state_file_zeus_intake) }

      it "calculates the proper value for line 14" do
        expect(instance.calculate[:IT213_LINE_14]).to eq 743
      end
    end

    context "when the client is not eligible because they didn't live in NY state all year" do
      before do
        intake.eligibility_lived_in_state = "no"
      end

      it "stops calculating IT213 after line 1 and sets IT213_LINE_14 to 0" do
        instance.calculate
        expect(instance.lines[:IT213_LINE_1].value).to eq(2) # did not live in NY state all year
        expect(instance.lines[:IT213_LINE_2]).to be_nil
        expect(instance.lines[:IT213_LINE_14].value).to eq(0)
      end
    end

    context "when the client is not eligible because they didn't claim federal CTC or have low enough AGI" do
      before do
        intake.direct_file_data.fed_wages = 200_000
        intake.direct_file_data.fed_ctc = 0
        intake.direct_file_data.fed_qualify_child = 0
      end

      it "stops calculating after line 3 and sets IT213_LINE_14 to 0" do
        instance.calculate
        expect(instance.lines[:IT213_LINE_1].value).to eq(1) # lived in NY state all year
        expect(instance.lines[:IT213_LINE_2].value).to eq(2) # did not claim federal CTC
        expect(instance.lines[:IT213_LINE_3].value).to eq(2) # did not have eligible wages
        expect(instance.lines[:IT213_LINE_4]).to be_nil
        expect(instance.lines[:IT213_LINE_14].value).to eq(0)
      end
    end

    context "when the client has claimed fed_ctc > 0 and worksheet A line 8 <= worksheet A line 12" do
      before do
        intake.direct_file_data.fed_ctc = 1_000
        intake.dependents.create(dob: 5.years.ago, ctc_qualifying: true)
      end

      it "calculated worksheets and finishes calculations" do
        instance.calculate
        expect(instance.lines[:IT213_LINE_1].value).to eq(1) # lived in NY state all year
        expect(instance.lines[:IT213_LINE_2].value).to eq(1) # claimed federal CTC
        expect(instance.lines[:IT213_LINE_3].value).to eq(1) # had eligible wages
        expect(instance.lines[:IT213_LINE_4].value).to eq(1)
        expect(instance.lines[:IT213_LINE_5].value).to eq(0)
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_1].value).to eq(1_000) # 1000 * 1 dependent
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_2].value).to eq(32_351)
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_3].value).to eq(0)
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_4].value).to eq(32_351)
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_5].value).to eq(75_000)
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_6].value).to be_nil
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_7].value).to eq(0)
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_8].value).to eq(1_000)
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_9].value).to eq(1_123)
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_10].value).to eq(0)
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_11].value).to eq(0)
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_12].value).to eq(1_123)
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_13].value).to eq(1_000)
        expect(instance.lines[:IT213_LINE_6].value).to eq(1_000)
        expect(instance.lines[:IT213_LINE_7].value).to eq(0)
        expect(instance.lines[:IT213_LINE_14].value).to eq(330)
      end
    end

    context 'when IT213_WORKSHEET_A_LINE_9 is nil' do
      before do
        intake.dependents.create(dob: 5.years.ago, ctc_qualifying: true)
        intake.dependents.create(dob: 3.years.ago, ctc_qualifying: true)
        intake.direct_file_data.fed_ctc = 1_000
        allow_any_instance_of(DirectFileData).to receive(:fed_tax).and_return(nil)
      end

      it 'avoids getting undefined method `-` for nil:NilClass (NoMethodError)' do
        instance.calculate
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_8].value).to be_positive
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_9].value).to be_zero
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_12].value).to be_zero
      end
    end


    context "when the client has claimed fed_ctc > 0, worksheet A line 8 > worksheet A line 12, and less than 3 dependents" do
      before do
        intake.dependents.create(dob: 5.years.ago, ctc_qualifying: true)
        intake.dependents.create(dob: 3.years.ago, ctc_qualifying: true)
        intake.direct_file_data.fed_ctc = 1_000
      end

      it "calculates worksheets and finishes calculations" do
        instance.calculate
        expect(instance.lines[:IT213_LINE_1].value).to eq(1)
        expect(instance.lines[:IT213_LINE_2].value).to eq(1)
        expect(instance.lines[:IT213_LINE_3].value).to eq(1)
        expect(instance.lines[:IT213_LINE_4].value).to eq(2) # dependents
        expect(instance.lines[:IT213_LINE_5].value).to eq(0)
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_1].value).to eq(2_000) # 1000 * 1 dependent
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_2].value).to eq(32_351)
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_3].value).to eq(0)
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_4].value).to eq(32_351)
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_5].value).to eq(75_000)
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_6].value).to be_nil
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_7].value).to eq(0)
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_8].value).to eq(2_000)
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_9].value).to eq(1_123)
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_10].value).to eq(0)
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_11].value).to eq(0)
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_12].value).to eq(1_123)
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_13].value).to eq(1_123)
        expect(instance.lines[:IT213_LINE_6].value).to eq(1_123)
        expect(instance.lines[:IT213_WORKSHEET_B_LINE_1].value).to eq(2_000)
        expect(instance.lines[:IT213_WORKSHEET_B_LINE_2].value).to eq(1_123)
        expect(instance.lines[:IT213_WORKSHEET_B_LINE_3].value).to eq(877)
        expect(instance.lines[:IT213_WORKSHEET_B_LINE_4A].value).to eq(21_000)
        expect(instance.lines[:IT213_WORKSHEET_B_LINE_4B].value).to eq(0)
        expect(instance.lines[:IT213_WORKSHEET_B_LINE_5].value).to eq(18_000)
        expect(instance.lines[:IT213_WORKSHEET_B_LINE_6].value).to eq(2_700)
        expect(instance.lines[:IT213_LINE_7].value).to eq(877)
        expect(instance.lines[:IT213_LINE_14].value).to eq(660)
      end
    end

    context "when the client has claimed fed_ctc > 0, worksheet A line 8 > worksheet A line 12, and has 3 dependents" do
      before do
        intake.dependents.create(dob: 5.years.ago, ctc_qualifying: true)
        intake.dependents.create(dob: 3.years.ago, ctc_qualifying: true)
        intake.dependents.create(dob: 1.years.ago, ctc_qualifying: true)
        intake.direct_file_data.fed_tax = 0
        intake.direct_file_data.fed_ctc = 1_000
      end

      it "calculates worksheets and finishes calculations" do
        instance.calculate
        expect(instance.lines[:IT213_LINE_1].value).to eq(1)
        expect(instance.lines[:IT213_LINE_2].value).to eq(1)
        expect(instance.lines[:IT213_LINE_3].value).to eq(1)
        expect(instance.lines[:IT213_LINE_4].value).to eq(3) # dependents
        expect(instance.lines[:IT213_LINE_5].value).to eq(0)
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_1].value).to eq(3_000) # 1000 * 1 dependent
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_2].value).to eq(32_351)
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_3].value).to eq(0)
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_4].value).to eq(32_351)
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_5].value).to eq(75_000)
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_6].value).to be_nil
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_7].value).to eq(0)
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_8].value).to eq(3_000)
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_9].value).to eq(0)
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_10].value).to eq(0)
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_11].value).to eq(0)
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_12].value).to eq(0)
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_13].value).to eq(0)
        expect(instance.lines[:IT213_LINE_6].value).to eq(0)
        expect(instance.lines[:IT213_WORKSHEET_B_LINE_1].value).to eq(3_000)
        expect(instance.lines[:IT213_WORKSHEET_B_LINE_2].value).to eq(0)
        expect(instance.lines[:IT213_WORKSHEET_B_LINE_3].value).to eq(3_000)
        expect(instance.lines[:IT213_WORKSHEET_B_LINE_4A].value).to eq(21_000)
        expect(instance.lines[:IT213_WORKSHEET_B_LINE_4B].value).to eq(0)
        expect(instance.lines[:IT213_WORKSHEET_B_LINE_5].value).to eq(18_000)
        expect(instance.lines[:IT213_WORKSHEET_B_LINE_6].value).to eq(2_700)
        expect(instance.lines[:IT213_WORKSHEET_B_LINE_7].value).to eq(0)
        expect(instance.lines[:IT213_WORKSHEET_B_LINE_8].value).to eq(2_700)
        expect(instance.lines[:IT213_WORKSHEET_B_LINE_9].value).to eq(2_700)
        expect(instance.lines[:IT213_LINE_7].value).to eq(2_700)
        expect(instance.lines[:IT213_LINE_14].value).to eq(891)
      end
    end

    context "with dependents with QlfyChildUnderAgeSSNLimtAmt instead of fed ctc" do
      let(:intake) { create(:state_file_taylor_intake) }

      it "calculates the proper value for line 14" do
        expect(instance.calculate[:IT213_LINE_14]).to eq 561
      end
    end
  end

  describe 'IT-213 cutoff for filing status' do
    context 'when filing status is single' do
      before do
        intake.direct_file_data.filing_status = 1 # single
      end
      it 'sets the cutoff correctly' do
        instance.calculate
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_5].value).to eq(75_000)
      end
    end

    context 'when filing status is mfj' do
      before do
        intake.direct_file_data.filing_status = 2 # mfj
      end
      it 'sets the cutoff correctly' do
        instance.calculate
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_5].value).to eq(110_000)
      end
    end

    context 'when filing status is mfs' do
      before do
        intake.direct_file_data.filing_status = 3 # mfs
      end
      it 'sets the cutoff correctly' do
        instance.calculate
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_5].value).to eq(55_000)
      end
    end

    context 'when filing status is hoh' do
      before do
        intake.direct_file_data.filing_status = 4 # hoh
      end
      it 'sets the cutoff correctly' do
        instance.calculate
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_5].value).to eq(75_000)
      end
    end

    context 'when filing status is qualifying_widow' do
      before do
        intake.direct_file_data.filing_status = 5 # qualifying_widow
      end
      it 'sets the cutoff correctly' do
        instance.calculate
        expect(instance.lines[:IT213_WORKSHEET_A_LINE_5].value).to eq(75_000)
      end
    end
  end

  describe "calculate IT-215" do
    describe '#calculate_line_12' do
      context "when federal EIC is not present" do
        let(:intake) { create :state_file_ny_intake, raw_direct_file_data: File.read(Rails.root.join("spec/fixtures/state_file/fed_return_xmls/2023/az/unemployment.xml")) }

        it "treats EIC as zero" do
          expect(instance.calculate[:IT215_LINE_12]).to eq(0)
          expect(instance.calculate[:IT201_LINE_65]).to eq(0)
        end
      end

      context "when federal EIC is present" do
        it "calculates the value" do
          expect(instance.calculate[:IT215_LINE_12]).to eq(533)
          expect(instance.calculate[:IT201_LINE_65]).to eq(533)
        end
      end
    end
  end

  # We aren't supporting IT-214 anymore, so the calculations being tested here aren't running. Restore these tests
  # if we ever implement this tax credit again.
  # describe '#calculate_it214' do
  #   context "when the client is not eligible because they didn't occupy their residence" do
  #     before do
  #       intake.occupied_residence = 2 # no
  #     end
  #
  #     it "stops calculating IT214 after line 2 and sets IT214_LINE_33 to 0" do
  #       instance.calculate
  #       expect(instance.lines[:IT214_LINE_2].value).to eq(2)
  #       expect(instance.lines[:IT214_LINE_3]).to be_nil
  #       expect(instance.lines[:IT214_LINE_33].value).to eq(0)
  #     end
  #   end
  #
  #   context "when the client is not eligible because the property value is over the limit" do
  #     before do
  #       intake.occupied_residence = 1 # yes
  #       intake.property_over_limit = 1 # yes
  #     end
  #
  #     it "stops calculating IT214 after line 3 and sets IT214_LINE_33 to 0" do
  #       instance.calculate
  #       expect(instance.lines[:IT214_LINE_3].value).to eq(1)
  #       expect(instance.lines[:IT214_LINE_4]).to be_nil
  #       expect(instance.lines[:IT214_LINE_33].value).to eq(0)
  #     end
  #   end
  #
  #   context "when the client is not eligible because they had public housing" do
  #     before do
  #       intake.occupied_residence = 1 # yes
  #       intake.property_over_limit = 2 # no
  #       intake.public_housing = 1 # yes
  #     end
  #
  #     it "stops calculating IT214 after line 5 and sets IT214_LINE_33 to 0" do
  #       instance.calculate
  #       expect(instance.lines[:IT214_LINE_5].value).to eq(1)
  #       expect(instance.lines[:IT214_LINE_6]).to be_nil
  #       expect(instance.lines[:IT214_LINE_33].value).to eq(0)
  #     end
  #   end
  #
  #   context "when the client is not eligible because they were in a nursing home" do
  #     before do
  #       intake.occupied_residence = 1 # yes
  #       intake.property_over_limit = 2 # no
  #       intake.public_housing = 2 # no
  #       intake.nursing_home = 1 # yes
  #     end
  #
  #     it "stops calculating IT214 after line 6 and sets IT214_LINE_33 to 0" do
  #       instance.calculate
  #       expect(instance.lines[:IT214_LINE_6].value).to eq(1)
  #       expect(instance.lines[:IT214_LINE_7]).to be_nil
  #       expect(instance.lines[:IT214_LINE_33].value).to eq(0)
  #     end
  #   end
  #
  #   context "when the client is not eligible because they had too much income" do
  #     before do
  #       intake.occupied_residence = 1 # yes
  #       intake.property_over_limit = 2 # no
  #       intake.public_housing = 2 # no
  #       intake.nursing_home = 2 # no
  #       intake.direct_file_data.fed_agi = 100000
  #       intake.direct_file_data.fed_wages = 100000
  #     end
  #
  #     it "stops calculating IT214 after line 16 and sets IT214_LINE_33 to 0" do
  #       instance.calculate
  #       expect(instance.lines[:IT214_LINE_16].value).to be > 18000
  #       expect(instance.lines[:IT214_LINE_17]).to be_nil
  #       expect(instance.lines[:IT214_LINE_33].value).to eq(0)
  #     end
  #   end
  #
  #   context "when the client is a renter and is ineligible because their rent is too high" do
  #     before do
  #       intake.occupied_residence = 1 # yes
  #       intake.property_over_limit = 2 # no
  #       intake.public_housing = 2 # no
  #       intake.nursing_home = 2 # no
  #       intake.household_rent_own = 1 # rent
  #       intake.household_rent_amount = 12000 # annual rent @ $1k/month
  #       intake.household_rent_adjustments = 6000 # 50% adjustment to $500/month, over the $450 eligibility threshold
  #       intake.direct_file_data.fed_agi = 2500
  #       intake.direct_file_data.fed_wages = 900
  #       intake.direct_file_data.fed_unemployment = 500
  #       intake.direct_file_data.fed_taxable_ssb = 400
  #     end
  #
  #     it "stops calculating IT214 after line 21 and sets IT214_LINE_33 to 0" do
  #       instance.calculate
  #       expect(instance.lines[:IT214_LINE_17].value).to eq(0.06)
  #       expect(instance.lines[:IT214_LINE_18].value).to eq(800)
  #       expect(instance.lines[:IT214_LINE_19].value).to eq(12000)
  #       expect(instance.lines[:IT214_LINE_19].value).to eq(12000)
  #       expect(instance.lines[:IT214_LINE_20].value).to eq(6000)
  #       expect(instance.lines[:IT214_LINE_21].value).to eq(500)
  #       expect(instance.lines[:IT214_LINE_22]).to be_nil
  #       expect(instance.lines[:IT214_LINE_33].value).to eq(0)
  #     end
  #   end
  #
  #   context "when the client is a renter and is ineligible because their non-subsidized rent is zero" do
  #     before do
  #       intake.occupied_residence = 1 # yes
  #       intake.property_over_limit = 2 # no
  #       intake.public_housing = 2 # no
  #       intake.nursing_home = 2 # no
  #       intake.household_rent_own = 1 # rent
  #       intake.household_rent_amount = 0
  #       intake.household_rent_adjustments = 0
  #       intake.direct_file_data.fed_agi = 2500
  #       intake.direct_file_data.fed_wages = 900
  #       intake.direct_file_data.fed_unemployment = 500
  #       intake.direct_file_data.fed_taxable_ssb = 400
  #     end
  #
  #     it "stops calculating IT214 after line 28 and sets IT214_LINE_33 to 0" do
  #       instance.calculate
  #       expect(instance.lines[:IT214_LINE_17].value).to eq(0.06)
  #       expect(instance.lines[:IT214_LINE_18].value).to eq(800)
  #       expect(instance.lines[:IT214_LINE_19].value).to eq(0)
  #       expect(instance.lines[:IT214_LINE_20].value).to eq(0)
  #       expect(instance.lines[:IT214_LINE_21].value).to eq(0)
  #       expect(instance.lines[:IT214_LINE_22].value).to eq(0)
  #       expect(instance.lines[:IT214_LINE_28].value).to eq(0)
  #       expect(instance.lines[:IT214_LINE_29]).to be_nil
  #       expect(instance.lines[:IT214_LINE_33].value).to eq(0)
  #     end
  #   end
  #
  #   context "when the client is a renter and their rent amount is eligible but they are ineligible because their income is too high relative to their rent" do
  #     before do
  #       intake.occupied_residence = 1 # yes
  #       intake.property_over_limit = 2 # no
  #       intake.public_housing = 2 # no
  #       intake.nursing_home = 2 # no
  #       intake.household_rent_own = 1 # rent
  #       intake.household_rent_amount = 6000 # annual rent @ $500/month
  #       intake.household_rent_adjustments = 3000 # 50% adjustment to $250/month, under the $450 eligibility threshold
  #       intake.direct_file_data.fed_agi = 2500
  #       intake.direct_file_data.fed_wages = 900
  #       intake.direct_file_data.fed_unemployment = 500
  #       intake.direct_file_data.fed_taxable_ssb = 400
  #     end
  #
  #     it "stops calculating IT214 after line 29 and sets IT214_LINE_33 to 0" do
  #       instance.calculate
  #       expect(instance.lines[:IT214_LINE_17].value).to eq(0.06)
  #       expect(instance.lines[:IT214_LINE_18].value).to eq(800)
  #       expect(instance.lines[:IT214_LINE_19].value).to eq(6000)
  #       expect(instance.lines[:IT214_LINE_20].value).to eq(3000)
  #       expect(instance.lines[:IT214_LINE_21].value).to eq(250)
  #       expect(instance.lines[:IT214_LINE_22].value).to eq(750)
  #       expect(instance.lines[:IT214_LINE_28].value).to eq(750) # if this is less than line 18 then the client is ineligible
  #       expect(instance.lines[:IT214_LINE_29].value).to eq(800)
  #       expect(instance.lines[:IT214_LINE_30]).to be_nil
  #       expect(instance.lines[:IT214_LINE_33].value).to eq(0)
  #     end
  #   end
  #
  #   context "when the client is a renter and they are eligible for the credit" do
  #     before do
  #       intake.occupied_residence = 1 # yes
  #       intake.property_over_limit = 2 # no
  #       intake.public_housing = 2 # no
  #       intake.nursing_home = 2 # no
  #       intake.household_rent_own = 1 # rent
  #       intake.household_rent_amount = 6000 # annual rent @ $500/month
  #       intake.household_rent_adjustments = 3000 # 50% adjustment to $250/month, under the $450 eligibility threshold
  #       intake.direct_file_data.fed_agi = 1250
  #       intake.direct_file_data.fed_wages = 450
  #       intake.direct_file_data.fed_unemployment = 250
  #       intake.direct_file_data.fed_taxable_ssb = 200
  #     end
  #
  #     it "finishes calculating IT214 and sets IT214_LINE_33 to the final credit value of $34" do
  #       instance.calculate
  #       expect(instance.lines[:IT214_LINE_17].value).to eq(0.06)
  #       expect(instance.lines[:IT214_LINE_18].value).to eq(683)
  #       expect(instance.lines[:IT214_LINE_19].value).to eq(6000)
  #       expect(instance.lines[:IT214_LINE_20].value).to eq(3000)
  #       expect(instance.lines[:IT214_LINE_21].value).to eq(250)
  #       expect(instance.lines[:IT214_LINE_22].value).to eq(750)
  #       expect(instance.lines[:IT214_LINE_28].value).to eq(750) # if this is less than line 18 then the client is ineligible
  #       expect(instance.lines[:IT214_LINE_29].value).to eq(683)
  #       expect(instance.lines[:IT214_LINE_30].value).to eq(67)
  #       expect(instance.lines[:IT214_LINE_31].value).to eq(34)
  #       expect(instance.lines[:IT214_LINE_32].value).to eq(53)
  #       expect(instance.lines[:IT214_LINE_33].value).to eq(34)
  #     end
  #   end
  #
  #   context "when the client is a homeowner and is ineligible because their property taxes and assessments were zero" do
  #     before do
  #       intake.occupied_residence = 1 # yes
  #       intake.property_over_limit = 2 # no
  #       intake.public_housing = 2 # no
  #       intake.nursing_home = 2 # no
  #       intake.household_rent_own = 2 # own
  #       intake.household_own_propety_tax = 0
  #       intake.household_own_assessments = 0
  #       intake.direct_file_data.fed_agi = 2500
  #       intake.direct_file_data.fed_wages = 900
  #       intake.direct_file_data.fed_unemployment = 500
  #       intake.direct_file_data.fed_taxable_ssb = 400
  #     end
  #
  #     it "stops calculating IT214 after line 28 and sets IT214_LINE_33 to 0" do
  #       instance.calculate
  #       expect(instance.lines[:IT214_LINE_17].value).to eq(0.06)
  #       expect(instance.lines[:IT214_LINE_18].value).to eq(800)
  #       expect(instance.lines[:IT214_LINE_23].value).to eq(0)
  #       expect(instance.lines[:IT214_LINE_24].value).to eq(0)
  #       expect(instance.lines[:IT214_LINE_25].value).to eq(0)
  #       expect(instance.lines[:IT214_LINE_27].value).to eq(0)
  #       expect(instance.lines[:IT214_LINE_28].value).to eq(0)
  #       expect(instance.lines[:IT214_LINE_29]).to be_nil
  #       expect(instance.lines[:IT214_LINE_33].value).to eq(0)
  #     end
  #   end
  #
  #   context "when the client is a homeowner with property tax and assessments but they are ineligible because their income is too high relative to their home costs" do
  #     before do
  #       intake.occupied_residence = 1 # yes
  #       intake.property_over_limit = 2 # no
  #       intake.public_housing = 2 # no
  #       intake.nursing_home = 2 # no
  #       intake.household_rent_own = 2 # own
  #       intake.household_own_propety_tax = 500
  #       intake.household_own_assessments = 250
  #       intake.direct_file_data.fed_agi = 2500
  #       intake.direct_file_data.fed_wages = 900
  #       intake.direct_file_data.fed_unemployment = 500
  #       intake.direct_file_data.fed_taxable_ssb = 400
  #     end
  #
  #     it "stops calculating IT214 after line 28 and sets IT214_LINE_33 to 0" do
  #       instance.calculate
  #       expect(instance.lines[:IT214_LINE_17].value).to eq(0.06)
  #       expect(instance.lines[:IT214_LINE_18].value).to eq(800)
  #       expect(instance.lines[:IT214_LINE_23].value).to eq(500)
  #       expect(instance.lines[:IT214_LINE_24].value).to eq(250)
  #       expect(instance.lines[:IT214_LINE_25].value).to eq(750)
  #       expect(instance.lines[:IT214_LINE_27].value).to eq(750)
  #       expect(instance.lines[:IT214_LINE_28].value).to eq(750) # if this is less than line 18 the client is ineligible
  #       expect(instance.lines[:IT214_LINE_29].value).to eq(800)
  #       expect(instance.lines[:IT214_LINE_30]).to be_nil
  #       expect(instance.lines[:IT214_LINE_33].value).to eq(0)
  #     end
  #   end
  #
  #   context "when the client is a homeowner and they are eligible for the credit" do
  #     before do
  #       intake.occupied_residence = 1 # yes
  #       intake.property_over_limit = 2 # no
  #       intake.public_housing = 2 # no
  #       intake.nursing_home = 2 # no
  #       intake.household_rent_own = 2 # own
  #       intake.household_own_propety_tax = 5000
  #       intake.household_own_assessments = 2500
  #       intake.direct_file_data.fed_agi = 2500
  #       intake.direct_file_data.fed_wages = 900
  #       intake.direct_file_data.fed_unemployment = 500
  #       intake.direct_file_data.fed_taxable_ssb = 400
  #     end
  #
  #     it "finishes calculating IT214 and sets IT214_LINE_33 to the final credit value of $49" do
  #       instance.calculate
  #       expect(instance.lines[:IT214_LINE_17].value).to eq(0.06)
  #       expect(instance.lines[:IT214_LINE_18].value).to eq(800)
  #       expect(instance.lines[:IT214_LINE_23].value).to eq(5000)
  #       expect(instance.lines[:IT214_LINE_24].value).to eq(2500)
  #       expect(instance.lines[:IT214_LINE_25].value).to eq(7500)
  #       expect(instance.lines[:IT214_LINE_27].value).to eq(7500)
  #       expect(instance.lines[:IT214_LINE_28].value).to eq(7500) # if this is less than line 18 the client is ineligible
  #       expect(instance.lines[:IT214_LINE_29].value).to eq(800)
  #       expect(instance.lines[:IT214_LINE_30].value).to eq(6700)
  #       expect(instance.lines[:IT214_LINE_31].value).to eq(3350)
  #       expect(instance.lines[:IT214_LINE_32].value).to eq(49)
  #       expect(instance.lines[:IT214_LINE_33].value).to eq(49)
  #     end
  #   end
  # end
end
