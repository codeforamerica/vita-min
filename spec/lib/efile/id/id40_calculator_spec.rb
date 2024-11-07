require 'rails_helper'

describe Efile::Id::Id40Calculator do
  let(:intake) { create(:state_file_id_intake) }
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
    before do
      3.times { intake.dependents.create! }
    end
    it "returns the number of dependents" do
      instance.calculate
      expect(instance.lines[:ID40_LINE_6C].value).to eq(3)
    end
  end

  describe "Line 6d: Total Exemptions" do
    it "sums lines 6a, 6b, and 6c" do
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

  describe "Line 32a: Permanent Building Fund" do
    context "has filing requirement, no blind filer, and no public assistance indicator" do
      before do
        intake.direct_file_data.total_income_amount = 40000
        intake.direct_file_data.total_itemized_or_standard_deduction_amount = 2112
        intake.received_id_public_assistance = "no"
      end
      it "returns 10" do
        instance.calculate
        expect(instance.lines[:ID40_LINE_32A].value).to eq(10)
      end
    end

    context "has no filing requirement, no blind filer, and no public assistance indicator" do
      before do
        intake.direct_file_data.total_income_amount = 2112
        intake.direct_file_data.total_itemized_or_standard_deduction_amount = 40000
        intake.received_id_public_assistance = "no"
      end
      it "returns 0" do
        instance.calculate
        expect(instance.lines[:ID40_LINE_32A].value).to eq(0)
      end
    end

    context "has filing requirement, blind filer, and has no public assistance indicator" do
      before do
        intake.direct_file_data.total_income_amount = 40000
        intake.direct_file_data.total_itemized_or_standard_deduction_amount = 2112
        intake.direct_file_data.set_primary_blind
        intake.received_id_public_assistance = "no"
      end
      it "returns 0" do
        instance.calculate
        expect(instance.lines[:ID40_LINE_32A].value).to eq(0)
      end
    end

    context "has filing requirement, no blind filer, and has public assistance indicator" do
      before do
        intake.direct_file_data.total_income_amount = 40000
        intake.direct_file_data.total_itemized_or_standard_deduction_amount = 2112
        intake.received_id_public_assistance = "yes"
      end
      it "returns 0" do
        instance.calculate
        expect(instance.lines[:ID40_LINE_32A].value).to eq(0)
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