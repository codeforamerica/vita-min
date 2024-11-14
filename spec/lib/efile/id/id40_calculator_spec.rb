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
      expect(instance.lines[:ID40_LINE_6C].value).to eq(3)
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
          let(:line_19) { 1000 }
          before do
            allow(calculator_instance).to receive(:calculate_line_19).and_return line_19
          end

          it "calculates the correct amount" do
            expected_result = (amount - line_19) * 5.695
            calculator_instance.calculate
            expect(calculator_instance.lines[:ID40_LINE_20].value).to eq expected_result
          end
        end
      end
    end

    context "must be positive value" do
      before do
        allow(instance).to receive(:calculate_line_19).and_return 10_000
      end

      it "returns 0 when calc is negative" do
        instance.calculate
        expect(instance.lines[:ID40_LINE_20].value).to eq 0
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
      end

      it "claims the correct credit" do
        instance.calculate
        expect(instance.lines[:ID40_LINE_43].value).to eq((12 * 4 * 10).round)
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
      context "which have no state tax withheld" do
        # Miranda has two W-2s with state tax withheld amount (507, 1502) and two 1099Rs with no state tax withheld
        # but we will not sync in this context to leave values blank in db
        let(:intake) {
          create(:state_file_id_intake,
                 raw_direct_file_data: StateFile::DirectFileApiResponseSampleService.new.read_xml('id_miranda_1099r'))
        }
        let!(:state_file1099_g) { create(:state_file1099_g, intake: intake, state_income_tax_withheld_amount: 0) }
        let!(:state_file1099_r) { create(:state_file1099_r, intake: intake, state_tax_withheld_amount: 0) }

        it "should return 0" do
          instance.calculate
          expect(instance.lines[:ID40_LINE_46].value).to eq(0)
        end
      end

      context "which have state tax withheld" do
        # Miranda has two W-2s with state tax withheld amount (507, 1502) and two 1099Rs with no state tax withheld
        let(:intake) {
          create(:state_file_id_intake,
                 :with_w2s_synced,
                 raw_direct_file_data: StateFile::DirectFileApiResponseSampleService.new.read_xml('id_miranda_1099r'))
        }
        let!(:state_file1099_g) { create(:state_file1099_g, intake: intake, state_income_tax_withheld_amount: 10) }
        let!(:state_file1099_r) { create(:state_file1099_r, intake: intake, state_tax_withheld_amount: 25) }

        it 'sums the ID tax withheld from w2s, 1099gs and 1099rs' do
          instance.calculate
          expect(instance.lines[:ID40_LINE_46].value).to eq(10 + 25 + 507 + 1502)
        end
      end
    end
  end
end