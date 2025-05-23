require 'rails_helper'

describe Efile::Id::Id40Calculator do
  let(:intake) { create(:state_file_id_intake, :single_filer_with_json) }
  let(:instance) do
    described_class.new(
      year: MultiTenantService.statefile.current_tax_year,
      intake: intake
    )
  end

  describe "Line 6a: Primary Taxpayer Exemption" do
    context "when taxpayer is not claimed as dependent" do
      it "returns 1" do
        allow(intake.direct_file_data).to receive(:claimed_as_dependent?).and_return(false)
        instance.calculate
        expect(instance.lines[:ID40_LINE_6A].value).to eq(1)
      end
    end

    context "when taxpayer is claimed as dependent" do
      it "returns 0" do
        allow(intake.direct_file_data).to receive(:claimed_as_dependent?).and_return(true)
        instance.calculate
        expect(instance.lines[:ID40_LINE_6A].value).to eq(0)
      end
    end
  end

  describe "Line 6b: Spouse Exemption" do
    context "when filing jointly and spouse is not a dependent" do
      it "returns 1" do
        allow(intake).to receive(:filing_status_mfj?).and_return(true)
        allow(intake.direct_file_data).to receive(:spouse_is_a_dependent?).and_return(false)
        instance.calculate
        expect(instance.lines[:ID40_LINE_6B].value).to eq(1)
      end
    end

    context "when not filing jointly or spouse is a dependent" do
      it "returns 0" do
        allow(intake).to receive(:filing_status_mfj?).and_return(false)
        instance.calculate
        expect(instance.lines[:ID40_LINE_6B].value).to eq(0)
      end
    end
  end

  describe "Line 6c: Dependents" do
    let(:intake) { create(:state_file_id_intake, :with_dependents) }

    it "returns the number of dependents" do
      instance.calculate
      expect(instance.lines[:ID40_LINE_6C].value).to eq(4)
    end
  end

  describe "Line 6d: Total Exemptions" do
    it "sums lines 6a, 6b, and 6c" do
      allow(instance).to receive(:line_or_zero).and_call_original
      allow(instance).to receive(:line_or_zero).with(:ID40_LINE_6A).and_return(1)
      allow(instance).to receive(:line_or_zero).with(:ID40_LINE_6B).and_return(1)
      allow(instance).to receive(:line_or_zero).with(:ID40_LINE_6C).and_return(2)

      instance.calculate
      expect(instance.lines[:ID40_LINE_6D].value).to eq(4)
    end
  end

  describe "Line 7: Federal Adjusted Gross Income" do
    before do
      intake.direct_file_data.fed_agi = 12_501
    end
    it "returns federal AGI from direct file data" do
      instance.calculate
      expect(instance.lines[:ID40_LINE_7].value).to eq(12_501)
    end
  end

  describe "Line 9: Total of lines 7 and 8" do
    it "sums lines 7 and 8" do
      allow(instance).to receive(:line_or_zero).and_call_original
      allow(instance).to receive(:line_or_zero).with(:ID40_LINE_7).and_return(5000)
      instance.calculate
      expect(instance.lines[:ID40_LINE_9].value).to eq(5000) # line 8 is always zero
    end
  end

  describe "Line 10: Subtractions from Form 39R" do
    it "returns value from ID39R form line 24" do
      allow(instance).to receive(:line_or_zero).and_call_original
      allow(instance).to receive(:line_or_zero).with(:ID39R_B_LINE_24).and_return(300)
      instance.calculate
      expect(instance.lines[:ID40_LINE_10].value).to eq(300)
    end
  end

  describe "Line 11: Idaho Adjusted Gross Income" do
    it "subtracts line 10 from line 9" do
      allow(instance).to receive(:line_or_zero).and_call_original
      allow(instance).to receive(:line_or_zero).with(:ID40_LINE_9).and_return(5200)
      allow(instance).to receive(:line_or_zero).with(:ID40_LINE_10).and_return(300)
      instance.calculate
      expect(instance.lines[:ID40_LINE_11].value).to eq(4900)
    end
  end

  describe "Line 19: Idaho taxable income" do
    before do
      allow(instance).to receive(:calculate_line_11).and_return 50
    end

    it "enters L11 - L16 if positive number" do
      intake.direct_file_data.total_itemized_or_standard_deduction_amount = 40
      instance.calculate
      expect(instance.lines[:ID40_LINE_19].value).to eq(10)
    end

    it "enters 0 if difference is negative number" do
      intake.direct_file_data.total_itemized_or_standard_deduction_amount = 60
      instance.calculate
      expect(instance.lines[:ID40_LINE_19].value).to eq(0)
    end
  end

  describe "Line 20: Idaho income tax" do
    {
      4673 => [:single, :married_filing_separately],
      9346 => [:married_filing_jointly, :head_of_household, :qualifying_widow]
    }.each do |amount, filing_statuses|
      filing_statuses.each do |filing_status|
        context "#{filing_status}" do
          let(:intake) { create(:state_file_id_intake, filing_status: filing_status) }
          let(:calculator_instance) { described_class.new(year: MultiTenantService.statefile.current_tax_year, intake: intake) }
          let(:line_19) { 10_000 }
          before do
            allow(calculator_instance).to receive(:calculate_line_19).and_return line_19
          end

          it "calculates the correct amount" do
            expected_result = ((line_19 - amount) * 0.05695).round
            calculator_instance.calculate
            expect(calculator_instance.lines[:ID40_LINE_20].value).to eq expected_result
          end
        end
      end
    end

    context "must be positive value" do
      before do
        allow(instance).to receive(:calculate_line_19).and_return 2_000
      end

      it "returns 0 when calc is negative" do
        instance.calculate
        expect(instance.lines[:ID40_LINE_20].value).to eq 0
      end
    end
  end

  describe "Line 21: Tax amount from line 20" do
    before do
      allow_any_instance_of(described_class).to receive(:calculate_line_20).and_return(1200)
      instance.calculate
    end

    it "equals line 20" do
      expect(instance.lines[:ID40_LINE_21].value).to eq(1200)
    end
  end

  describe "Line 25: Child Tax Credit" do
    context "when there are no dependents" do
      it "calculates correct child care credit to zero" do
        allow(instance).to receive(:line_or_zero).and_call_original
        instance.calculate
        expect(instance.lines[:ID40_LINE_25].value).to eq(0)
      end
    end

    context "when there are dependents" do
      let(:intake) { create(:state_file_id_intake, :with_qualifying_dependents) }

      context "when worksheet line 2 is less than worksheet line 7" do
        it "calculates correct child care credit" do
          allow(instance).to receive(:line_or_zero).and_call_original
          allow(instance).to receive(:line_or_zero).with(:ID40_LINE_20).and_return(1150)
          allow(instance).to receive(:line_or_zero).with(:ID40_LINE_22).and_return(50)
          allow(instance).to receive(:line_or_zero).with(:ID40_LINE_23).and_return(50)
          allow(instance).to receive(:line_or_zero).with(:ID40_LINE_24).and_return(50)
          # line 7 is 1000 (line 20 - sum(22-24)) and line 2 is 615 (three dependents * 205)
          instance.calculate
          expect(instance.lines[:ID40_LINE_25].value).to eq(3 * 205)
        end
      end

      context "when worksheet line 2 is more than worksheet line 7" do
        it "calculates correct child care credit" do
          allow(instance).to receive(:line_or_zero).and_call_original
          allow(instance).to receive(:line_or_zero).with(:ID40_LINE_20).and_return(200)
          allow(instance).to receive(:line_or_zero).with(:ID40_LINE_22).and_return(50)
          allow(instance).to receive(:line_or_zero).with(:ID40_LINE_23).and_return(50)
          allow(instance).to receive(:line_or_zero).with(:ID40_LINE_24).and_return(50)
          # line 7 is 50 (line 20 - sum(22-24)) and line 2 is 410 (two dependents * 205
          instance.calculate
          expect(instance.lines[:ID40_LINE_25].value).to eq(50)
        end
      end
    end
  end

  describe "Line 26: Total Credits" do
    it "adds line 23 and 25" do
      allow(instance).to receive(:line_or_zero).and_call_original
      allow(instance).to receive(:line_or_zero).with(:ID40_LINE_23).and_return(500)
      allow(instance).to receive(:line_or_zero).with(:ID40_LINE_25).and_return(300)
      instance.calculate
      expect(instance.lines[:ID40_LINE_26].value).to eq(800)
    end
  end

  describe "Line 27: Credits" do
    context "when 26 is greater than 21" do
      it "returns 0" do
        allow(instance).to receive(:line_or_zero).and_call_original
        allow_any_instance_of(described_class).to receive(:calculate_line_20).and_return(100)
        allow(instance).to receive(:line_or_zero).with(:ID40_LINE_26).and_return(300)
        instance.calculate
        expect(instance.lines[:ID40_LINE_27].value).to eq(0)
      end
    end

    context "when 26 is less than 21" do
      it "subtracts 26 from 21" do
        allow(instance).to receive(:line_or_zero).and_call_original
        allow_any_instance_of(described_class).to receive(:calculate_line_20).and_return(500)
        allow(instance).to receive(:line_or_zero).with(:ID40_LINE_26).and_return(300)
        instance.calculate
        expect(instance.lines[:ID40_LINE_27].value).to eq(200)
      end
    end
  end

  describe "Line 29: State Use Tax" do
    let(:purchase_amount) { nil }

    before do
      intake.update(total_purchase_amount: purchase_amount)
    end

    context "when taxpayer has unpaid sales use tax" do
      it "returns 0 if no purchase amount" do
        allow(intake).to receive(:has_unpaid_sales_use_tax?).and_return(true)
        instance.calculate
        expect(instance.lines[:ID40_LINE_29].value).to eq(0)
      end

      context "has valid purchase amount" do
        let(:purchase_amount) { 100 }

        it "returns 0.06 times the purchase amount if present" do
          allow(intake).to receive(:has_unpaid_sales_use_tax?).and_return(true)
          instance.calculate
          expect(instance.lines[:ID40_LINE_29].value).to eq(6)
        end
      end
    end

    context "when taxpayer does not have unpaid sales use tax" do
      it "returns 0" do
        allow(intake).to receive(:has_unpaid_sales_use_tax?).and_return(false)
        instance.calculate
        expect(instance.lines[:ID40_LINE_29].value).to eq(0)
      end
    end
  end

  describe "Line 32a: Permanent Building Fund" do
    context "has filing requirement, no blind filer, and no public assistance indicator" do
      let(:intake) { create(:state_file_id_intake, :filing_requirement) }

      before do
        intake.received_id_public_assistance = "no"
      end

      it "returns 10" do
        instance.calculate
        expect(instance.lines[:ID40_LINE_32A].value).to eq(10)
      end
    end

    context "has no filing requirement, no blind filer, and no public assistance indicator" do
      let(:intake) { create(:state_file_id_intake, :no_filing_requirement) }

      before do
        intake.received_id_public_assistance = nil
      end

      it "returns 0" do
        instance.calculate
        expect(instance.lines[:ID40_LINE_32A].value).to eq(0)
      end
    end

    context "has filing requirement, blind filer, and has no public assistance indicator" do
      let(:intake) { create(:state_file_id_intake, :filing_requirement) }

      before do
        intake.direct_file_data.primary_blind = "X"
        intake.received_id_public_assistance = "no"
      end

      it "returns 0" do
        instance.calculate
        expect(instance.lines[:ID40_LINE_32A].value).to eq(0)
      end
    end

    context "has filing requirement, no blind filer, and has public assistance indicator" do
      let(:intake) { create(:state_file_id_intake, :filing_requirement) }

      before do
        intake.received_id_public_assistance = "yes"
      end

      it "returns 0" do
        instance.calculate
        expect(instance.lines[:ID40_LINE_32A].value).to eq(0)
      end
    end
  end

  describe "Lines 34-41: Donation Lines" do
    let(:intake) { create(:state_file_id_intake, :single_filer_with_json) }


    context "when all donation amounts are provided" do
      before do
        allow(intake).to receive(:nongame_wildlife_fund_donation).and_return(50.00)
        allow(intake).to receive(:childrens_trust_fund_donation).and_return(30.00)
        allow(intake).to receive(:special_olympics_donation).and_return(20.00)
        allow(intake).to receive(:guard_reserve_family_donation).and_return(40.00)
        allow(intake).to receive(:american_red_cross_fund_donation).and_return(25.00)
        allow(intake).to receive(:veterans_support_fund_donation).and_return(10.00)
        allow(intake).to receive(:food_bank_fund_donation).and_return(60.00)
        allow(intake).to receive(:opportunity_scholarship_program_donation).and_return(100.00)
      end

      it "correctly assigns line 34" do
        instance.calculate
        expect(instance.lines[:ID40_LINE_34].value).to eq(50.00)
      end

      it "correctly assigns line 35" do
        instance.calculate
        expect(instance.lines[:ID40_LINE_35].value).to eq(30.00)
      end

      it "correctly assigns line 36" do
        instance.calculate
        expect(instance.lines[:ID40_LINE_36].value).to eq(20.00)
      end

      it "correctly assigns line 37" do
        instance.calculate
        expect(instance.lines[:ID40_LINE_37].value).to eq(40.00)
      end

      it "correctly assigns line 38" do
        instance.calculate
        expect(instance.lines[:ID40_LINE_38].value).to eq(25.00)
      end

      it "correctly assigns line 39" do
        instance.calculate
        expect(instance.lines[:ID40_LINE_39].value).to eq(10.00)
      end

      it "correctly assigns line 40" do
        instance.calculate
        expect(instance.lines[:ID40_LINE_40].value).to eq(60.00)
      end

      it "correctly assigns line 41" do
        instance.calculate
        expect(instance.lines[:ID40_LINE_41].value).to eq(100.00)
      end
    end
  end

  describe "Line 33 and 42: Total Credits" do
    it "calculates line 33 as the sum of lines 29 and 32, and line 42 as the sum of relevant lines" do
      allow(instance).to receive(:line_or_zero).and_call_original

      allow(instance).to receive(:line_or_zero).with(:ID40_LINE_29).and_return(300)
      allow(instance).to receive(:line_or_zero).with(:ID40_LINE_32A).and_return(300)

      allow(instance).to receive(:line_or_zero).with(:ID40_LINE_33).and_return(600)
      allow(instance).to receive(:line_or_zero).with(:ID40_LINE_34).and_return(50)
      allow(instance).to receive(:line_or_zero).with(:ID40_LINE_35).and_return(30)
      allow(instance).to receive(:line_or_zero).with(:ID40_LINE_36).and_return(20)
      allow(instance).to receive(:line_or_zero).with(:ID40_LINE_37).and_return(40)
      allow(instance).to receive(:line_or_zero).with(:ID40_LINE_38).and_return(25)
      allow(instance).to receive(:line_or_zero).with(:ID40_LINE_39).and_return(10)
      allow(instance).to receive(:line_or_zero).with(:ID40_LINE_40).and_return(60)
      allow(instance).to receive(:line_or_zero).with(:ID40_LINE_41).and_return(100)

      instance.calculate

      expect(instance.lines[:ID40_LINE_33].value).to eq(600)
      expect(instance.lines[:ID40_LINE_42].value).to eq(935)
    end
  end


  describe "Line 43: Grocery Credit" do
    context "primary is claimed as dependent" do
      let(:intake) { create(:state_file_id_intake, :single_filer_with_json) }
      before do
        allow(intake.direct_file_data).to receive(:claimed_as_dependent?).and_return(true)
      end

      it "claims the correct credit" do
        instance.calculate
        expect(instance.lines[:ID40_LINE_43].value).to eq(0)
      end
    end

    context "household does not have ineligible months" do
      let(:intake) { create(:state_file_id_intake, :with_dependents) }

      before do
        intake.household_has_grocery_credit_ineligible_months_no!
        intake.primary_has_grocery_credit_ineligible_months_no!
        intake.dependents[0].id_has_grocery_credit_ineligible_months_no!
        intake.dependents[1].id_has_grocery_credit_ineligible_months_no!
        intake.dependents[2].id_has_grocery_credit_ineligible_months_no!
        intake.dependents[3].id_has_grocery_credit_ineligible_months_no!
      end

      it "claims the correct credit" do
        instance.calculate
        expect(instance.lines[:ID40_LINE_43].value).to eq((12 * 5 * 10).round)
      end
    end

    context "primary has ineligible months" do
      let(:intake) { create(:state_file_id_intake, :single_filer_with_json) }

      before do
        intake.household_has_grocery_credit_ineligible_months_yes!

        intake.primary_has_grocery_credit_ineligible_months_yes!
        intake.primary_months_ineligible_for_grocery_credit = 3
      end

      context "primary is 65 or older" do
        before do
          intake.primary_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 66, 1, 1)
        end

        it "claims the correct credit" do
          instance.calculate
          expect(instance.lines[:ID40_LINE_43].value).to eq((9 * 11.67).round)
        end

      end

      context "primary is under 65" do
        before do
          intake.primary_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 63, 1, 1)
        end

        it "claims the correct credit" do
          instance.calculate
          expect(instance.lines[:ID40_LINE_43].value).to eq((9 * 10).round)
        end
      end
    end

    context "spouse has ineligible months" do
      let(:intake) { create(:state_file_id_intake, :mfj_filer_with_json) }

      before do
        intake.household_has_grocery_credit_ineligible_months_yes!

        intake.primary_has_grocery_credit_ineligible_months_yes!
        intake.primary_months_ineligible_for_grocery_credit = 12

        intake.spouse_has_grocery_credit_ineligible_months_yes!
        intake.spouse_months_ineligible_for_grocery_credit = 3
      end

      context "spouse is 65 or older" do
        before do
          intake.spouse_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 66, 1, 1)
        end

        it "claims the correct credit" do
          instance.calculate
          expect(instance.lines[:ID40_LINE_43].value).to eq((9 * 11.67).round)
        end
      end

      context "spouse is under 65" do
        before do
          intake.spouse_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 63, 1, 1)
        end

        it "claims the correct credit" do
          instance.calculate
          expect(instance.lines[:ID40_LINE_43].value).to eq((9 * 10).round)
        end
      end
    end

    context "dependent has ineligible months" do
      let(:intake) { create(:state_file_id_intake, :with_dependents) }

      before do
        intake.household_has_grocery_credit_ineligible_months_yes!

        intake.primary_has_grocery_credit_ineligible_months_yes!
        intake.primary_months_ineligible_for_grocery_credit = 12

        intake.dependents[0].id_has_grocery_credit_ineligible_months_yes!
        intake.dependents[0].id_months_ineligible_for_grocery_credit = 3

        intake.dependents[1].id_has_grocery_credit_ineligible_months_unfilled!
        intake.dependents[1].id_months_ineligible_for_grocery_credit = 0

        intake.dependents[2].id_has_grocery_credit_ineligible_months_no!
        intake.dependents[2].id_months_ineligible_for_grocery_credit = nil

        intake.dependents[3].id_has_grocery_credit_ineligible_months_yes!
        intake.dependents[3].id_months_ineligible_for_grocery_credit = 12
      end

      it "claims the correct credit" do
        instance.calculate
        expect(instance.lines[:ID40_LINE_43].value).to eq(((9 + 12 + 12) * 10).round)
      end
    end

    context "donate the credit" do
      let(:intake) { create(:state_file_id_intake, :mfj_filer_with_json) }

      before do
        intake.household_has_grocery_credit_ineligible_months_no!
        intake.donate_grocery_credit_yes!
      end

      it "checks the box and doesn't claim the credit" do
        instance.calculate
        expect(instance.lines[:ID40_LINE_43_WORKSHEET].value).to eq(240)
        expect(instance.lines[:ID40_LINE_43_DONATE].value).to eq(true)
        expect(instance.lines[:ID40_LINE_43].value).to eq(0)
      end
    end
  end

  describe "Line 46: State Tax Withheld" do
    context "when there are no income forms" do
      it "should return 0" do
        instance.calculate
        expect(instance.lines[:ID40_LINE_46].value).to eq(0)
      end
    end

    context "when there are income forms" do
      # Miranda has two W-2s with state tax withheld amount (507, 1502) and two 1099Rs with no state tax withheld
      # but we will not sync in this context to leave values blank in db
      let(:intake) {
        create(:state_file_id_intake,
               raw_direct_file_data: StateFile::DirectFileApiResponseSampleService.new.read_xml('id_miranda_1099r'))
      }
      let!(:state_file1099_g) { create(:state_file1099_g, intake: intake, state_income_tax_withheld_amount: 0) }
      let!(:state_file1099_r) { create(:state_file1099_r, intake: intake, state_tax_withheld_amount: 0) }

      context "which have 0 state tax withheld" do
        it "should return 0" do
          instance.calculate
          expect(instance.lines[:ID40_LINE_46].value).to eq(0)
        end
      end

      context "which have nil state tax withheld" do
        let(:intake) {
          create(:state_file_id_intake,
                 :with_eligible_1099r_income,
                 raw_direct_file_data: StateFile::DirectFileApiResponseSampleService.new.read_xml('id_miranda_1099r'),
          )
        }
        before do
          intake.state_file1099_rs.first&.update!(state_tax_withheld_amount: nil)
        end

        it 'sums the ID tax withheld from 1099gs and 1099rs without error' do
          instance.calculate
          expect(instance.lines[:ID40_LINE_46].value).to eq(0)
        end
      end

      context "which have state tax withheld on eligible 1099s" do
        # Miranda has two W-2s with state tax withheld amount (507, 1502) and 1099R with 200 amount
        let(:intake) {
          create(:state_file_id_intake,
                 :with_w2s_synced, :with_eligible_1099r_income,
                 raw_direct_file_data: StateFile::DirectFileApiResponseSampleService.new.read_xml('id_miranda_1099r'))
        }
        let!(:state_file1099_g) { create(:state_file1099_g, intake: intake, state_income_tax_withheld_amount: 10) }

        it 'sums the ID tax withheld from w2s, 1099gs and 1099rs' do
          instance.calculate
          expect(instance.lines[:ID40_LINE_46].value).to eq(10 + 507 + 1502 + 200)
        end

        context "which have nil state_income_tax_amount" do
          before do
            intake.state_file_w2s.first&.update(state_income_tax_amount: nil)
          end

          it 'sums the ID tax withheld from 1099gs and 1099rs without error' do
            instance.calculate
            expect(instance.lines[:ID40_LINE_46].value).to eq(10 + 1502 + 200)
          end
        end
      end

      context "which have state tax withheld on ineligible 1099s" do
        # Miranda has two W-2s with state tax withheld amount (507, 1502) and 1099R with 200 amount
        let(:intake) {
          create(:state_file_id_intake,
                 :with_w2s_synced, :with_ineligible_1099r_income,
                 raw_direct_file_data: StateFile::DirectFileApiResponseSampleService.new.read_xml('id_miranda_1099r'))
        }
        let!(:state_file1099_g) { create(:state_file1099_g, intake: intake, state_income_tax_withheld_amount: 10) }

        it 'sums the ID tax withheld from w2s, 1099gs and 1099rs' do
          instance.calculate
          expect(instance.lines[:ID40_LINE_46].value).to eq(10 + 507 + 1502 + 200)
        end

        context 'state_tax_withheld is nil' do
          before do
            intake.state_file1099_rs.first.update(state_tax_withheld_amount: nil)
          end

          it 'sums the ID tax withheld from w2s, 1099gs and 1099rs' do
            instance.calculate
            expect(instance.lines[:ID40_LINE_46].value).to eq(10 + 507 + 1502)
          end
        end
      end
    end
  end

  describe "Line 47: Estimated Payments" do
    let!(:intake) { create(:state_file_id_intake) }
    context "when there are no extension payments or prior year payments" do
      before do
        intake.paid_extension_payments = 'no'
        intake.paid_prior_year_refund_payments = 'no'
        allow(intake).to receive(:extension_payments_amount).and_return 45
        allow(intake).to receive(:prior_year_refund_payments_amount).and_return 100
      end

      it "returns 0" do
        instance.calculate
        expect(instance.lines[:ID40_LINE_47].value).to eq(0)
      end
    end

    context "when there are extension payments but no prior year payments" do
      before do
        intake.paid_extension_payments = 'yes'
        intake.paid_prior_year_refund_payments = 'no'
        allow(intake).to receive(:extension_payments_amount).and_return 2112
      end

      it "returns the amount of the extension payment" do
        instance.calculate
        expect(instance.lines[:ID40_LINE_47].value).to eq(2112)
      end
    end

    context "when there are prior year payments and no extension payments" do
      before do
        intake.paid_extension_payments = 'no'
        intake.paid_prior_year_refund_payments = 'yes'
        allow(intake).to receive(:prior_year_refund_payments_amount).and_return 2112
      end

      it "returns the amount of the extension payment" do
        instance.calculate
        expect(instance.lines[:ID40_LINE_47].value).to eq(2112)
      end
    end

    context "when there are prior year payments and extension payments" do
      before do
        intake.paid_extension_payments = 'yes'
        intake.paid_prior_year_refund_payments = 'yes'
        allow(intake).to receive(:prior_year_refund_payments_amount).and_return 2112
        allow(intake).to receive(:extension_payments_amount).and_return 2112
      end

      it "returns the amount of the extension payment" do
        instance.calculate
        expect(instance.lines[:ID40_LINE_47].value).to eq(4224)
      end
    end
  end

  describe "refund_or_owed_amount" do
    it "subtracts owed amount from refund amount" do
      allow(instance).to receive(:calculate_line_56).and_return 0
      allow(instance).to receive(:calculate_line_54).and_return -30
      instance.calculate
      expect(instance.refund_or_owed_amount).to eq(30)
    end
  end

  describe "Line 50: Total payments and other credits" do
    before do
      allow_any_instance_of(described_class).to receive(:calculate_line_43).and_return(1200)
      allow_any_instance_of(described_class).to receive(:calculate_line_46).and_return(1350)
      allow_any_instance_of(described_class).to receive(:calculate_line_47).and_return(2112)

      instance.calculate
    end

    it "should return the sum of lines 43, 46 and 47" do
      expect(instance.lines[:ID40_LINE_50].value).to eq(4662)
    end
  end

  describe "Line 51: Tax Due" do
    context "when line 42 is more than line 50" do
      before do
        allow_any_instance_of(described_class).to receive(:calculate_line_42).and_return(2000)
        allow_any_instance_of(described_class).to receive(:calculate_line_50).and_return(1000)
        instance.calculate
      end

      it "should return the line 42 minus line 50 minus line 47" do
        expect(instance.lines[:ID40_LINE_51].value).to eq(1000)
      end
    end

    context "when line 42 is less than line 50" do
      before do
        allow_any_instance_of(described_class).to receive(:calculate_line_42).and_return(100)
        allow_any_instance_of(described_class).to receive(:calculate_line_50).and_return(1000)
        instance.calculate
      end

      it "should return nil" do
        expect(instance.lines[:ID40_LINE_51].value).to eq(nil)
      end
    end
  end

  describe "Line 54: Total due" do
    before do
      allow_any_instance_of(described_class).to receive(:calculate_line_51).and_return(1200)
      instance.calculate
    end

    it "should return line 51" do
      expect(instance.lines[:ID40_LINE_54].value).to eq(1200)
    end
  end

  describe "Line 55: Overpaid" do
    context "when line 42 is less than line 50" do
      before do
        allow_any_instance_of(described_class).to receive(:calculate_line_42).and_return(1000)
        allow_any_instance_of(described_class).to receive(:calculate_line_50).and_return(2000)
        instance.calculate
      end

      it "should return the line 50 minus line 42" do
        expect(instance.lines[:ID40_LINE_55].value).to eq(1000)
      end
    end

    context "when line 42 is more than line 50" do
      before do
        allow_any_instance_of(described_class).to receive(:calculate_line_42).and_return(3000)
        allow_any_instance_of(described_class).to receive(:calculate_line_50).and_return(1000)
        instance.calculate
      end

      it "should return nil" do
        expect(instance.lines[:ID40_LINE_55].value).to eq(nil)
      end
    end
  end

  describe "Line 56: Refund" do
    before do
      allow_any_instance_of(described_class).to receive(:calculate_line_55).and_return(1200)
      instance.calculate
    end

    it "should return the line 55" do
      expect(instance.lines[:ID40_LINE_56].value).to eq(1200)
    end
  end
end