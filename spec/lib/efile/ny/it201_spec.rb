require 'rails_helper'

describe Efile::Ny::It201 do
  let(:intake) { create(:state_file_ny_intake, eligibility_lived_in_state: 1) }
  let!(:dependent) { intake.dependents.create(dob: 7.years.ago) }
  let(:instance) do
    described_class.new(
      year: MultiTenantService.statefile.current_tax_year,
      intake: intake
    )
  end

  describe '#calculate_line_17' do
    it "adds up some of the prior lines" do
      expect(instance.calculate[:IT201_LINE_17]).to eq(35151)
    end
  end

  # TODO: flesh out this test suite on the IT213 calculations
  describe '#calculate_it213' do
    context "when the client is not eligible because they didn't live in NY state all year" do
      before do
        intake.eligibility_lived_in_state = 2 # no
      end

      it "stops calculating IT213 after line 1 and sets IT213_LINE_14 to 0" do
        instance.calculate
        expect(instance.lines[:IT213_LINE_1].value).to eq(2)
        expect(instance.lines[:IT213_LINE_2]).to be_nil
        expect(instance.lines[:IT213_LINE_14].value).to eq(0)
      end
    end

    context "when the client is not eligible because they didn't claim federal CTC or have low enough AGI" do
      before do
        intake.direct_file_data.fed_wages = 200000
        intake.direct_file_data.fed_ctc = 0
      end

      it "stops calculating after line 3 and sets IT213_LINE_14 to 0" do
        instance.calculate
        expect(instance.lines[:IT213_LINE_1].value).to eq(1)
        expect(instance.lines[:IT213_LINE_2].value).to eq(2)
        expect(instance.lines[:IT213_LINE_3].value).to eq(2)
        expect(instance.lines[:IT213_LINE_4]).to be_nil
        expect(instance.lines[:IT213_LINE_14].value).to eq(0)
      end
    end

    context "when the client is eligible and has an IT213 credit" do
      it "populates line 14 with the final credit amount" do
        instance.calculate
        expect(instance.lines[:IT213_LINE_14].value).to eq(330)
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
