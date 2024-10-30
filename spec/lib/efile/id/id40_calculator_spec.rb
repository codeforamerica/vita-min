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
      allow(instance).to receive(:line_or_zero).and_return(nil)
      allow(instance).to receive(:line_or_zero).with(:ID40_LINE_6A).and_return(1)
      allow(instance).to receive(:line_or_zero).with(:ID40_LINE_6B).and_return(1)
      allow(instance).to receive(:line_or_zero).with(:ID40_LINE_6C).and_return(2)

      instance.calculate
      expect(instance.lines[:ID40_LINE_6D].value).to eq(4)
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

    context "primary has ineligible months" do
      let(:intake) { create(:state_file_id_intake, :single_filer_with_json) }

      before do
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
end