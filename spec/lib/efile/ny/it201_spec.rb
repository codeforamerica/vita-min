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

  describe 'Line 39 New York State tax from tables' do
    context 'when the filing status is single' do
      before do
        intake.direct_file_data.filing_status = 1 # single
        intake.direct_file_data.fed_wages = 20_000
        intake.direct_file_data.fed_taxable_income = 20_000
        intake.direct_file_data.fed_taxable_ssb = 0
        intake.direct_file_data.fed_unemployment = 0
      end

      it 'sets the correct tax amount' do
        instance.calculate
        expect(instance.lines[:IT201_LINE_38].value).to eq(28_200) # taxable income
        expect(instance.lines[:IT201_LINE_39].value).to eq(1_437)
      end
    end

    context 'when the filing status is mfj' do
      before do
        intake.direct_file_data.filing_status = 2 # mfj
        intake.direct_file_data.fed_wages = 20_000
        intake.direct_file_data.fed_taxable_income = 20_000
        intake.direct_file_data.fed_taxable_ssb = 0
        intake.direct_file_data.fed_unemployment = 0
      end

      it 'sets the correct tax amount' do
        instance.calculate
        expect(instance.lines[:IT201_LINE_38].value).to eq(20_150) # taxable income
        expect(instance.lines[:IT201_LINE_39].value).to eq(821)
      end
    end

    context 'when the filing status is mfs' do
      before do
        intake.direct_file_data.filing_status = 3 # mfs
        intake.direct_file_data.fed_wages = 20_000
        intake.direct_file_data.fed_taxable_income = 20_000
        intake.direct_file_data.fed_taxable_ssb = 0
        intake.direct_file_data.fed_unemployment = 0
      end

      it 'sets the correct tax amount' do
        instance.calculate
        expect(instance.lines[:IT201_LINE_38].value).to eq(28_200) # taxable income
        expect(instance.lines[:IT201_LINE_39].value).to eq(1_437)
      end
    end

    context 'when the filing status is hoh' do
      before do
        intake.direct_file_data.filing_status = 4 # hoh
        intake.direct_file_data.fed_wages = 20_000
        intake.direct_file_data.fed_taxable_income = 20_000
        intake.direct_file_data.fed_taxable_ssb = 0
        intake.direct_file_data.fed_unemployment = 0
      end

      it 'sets the correct tax amount' do
        instance.calculate
        expect(instance.lines[:IT201_LINE_38].value).to eq(25_000) # taxable income
        expect(instance.lines[:IT201_LINE_39].value).to eq(1_141)
      end
    end

    context 'when the filing status is qw' do
      before do
        intake.direct_file_data.filing_status = 5 # qw
        intake.direct_file_data.fed_wages = 20_000
        intake.direct_file_data.fed_taxable_income = 20_000
        intake.direct_file_data.fed_taxable_ssb = 0
        intake.direct_file_data.fed_unemployment = 0
      end

      it 'sets the correct tax amount' do
        instance.calculate
        expect(instance.lines[:IT201_LINE_38].value).to eq(20_150) # taxable income
        expect(instance.lines[:IT201_LINE_39].value).to eq(821)
      end
    end
  end

  describe 'Line 40 NYS household credit' do
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
  end

  describe 'Line 48 NYC household credit' do
    context 'when the filer has been claimed as a dependent' do
      before do
        intake.direct_file_data.primary_claim_as_dependent = "X"
        intake.direct_file_data.fed_wages = 2_000
        intake.direct_file_data.fed_taxable_income = 2_000
        intake.direct_file_data.fed_taxable_ssb = 0
        intake.direct_file_data.fed_unemployment = 0
        intake.nyc_full_year_resident = 1 # yes
      end

      it 'sets the credit to 0 because the filer is ineligible' do
        instance.calculate
        expect(instance.lines[:IT201_LINE_48].value).to eq(0)
      end
    end

    context 'when the filer was not a full year NYC resident' do
      before do
        intake.nyc_full_year_resident = 2 # no
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

  describe 'Line 69 NYC school tax credit' do
    context 'when the filer has been claimed as a dependent' do
      before do
        intake.direct_file_data.primary_claim_as_dependent = "X"
        intake.nyc_full_year_resident = 1 # yes
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
        intake.nyc_full_year_resident = 2 # no
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
        intake.nyc_full_year_resident = 1 # yes
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
        intake.nyc_full_year_resident = 1 # yes
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
        intake.nyc_full_year_resident = 1 # yes
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
        intake.nyc_full_year_resident = 1 # yes
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
        intake.nyc_full_year_resident = 1 # yes
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
        intake.nyc_full_year_resident = 1 # yes
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
        expect(instance.calculate[:IT213_LINE_14]).to eq 900 # TODO: verify this result for zeus
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
      end

      it "calculated worksheets and finishes calculations" do
        instance.calculate
        expect(instance.lines[:IT213_LINE_1].value).to eq(1) # lived in NY state all year
        expect(instance.lines[:IT213_LINE_2].value).to eq(1) # claimed federal CTC
        expect(instance.lines[:IT213_LINE_3].value).to eq(1) # had eligible wages
        expect(instance.lines[:IT213_LINE_4].value).to eq(1) # one dependent
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

    context "when the client has claimed fed_ctc > 0, worksheet A line 8 > worksheet A line 12, and less than 3 dependents" do
      before do
        intake.dependents.create(dob: 5.years.ago)
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
        intake.dependents.create(dob: 5.years.ago)
        intake.dependents.create(dob: 3.years.ago)
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
        let(:intake) { create :state_file_ny_intake, raw_direct_file_data: File.read(Rails.root.join("spec/fixtures/files/fed_return_unemployment_az.xml")) }

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
