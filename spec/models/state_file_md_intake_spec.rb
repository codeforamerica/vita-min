require 'rails_helper'

RSpec.describe StateFileMdIntake, type: :model do
  describe "#calculate_age" do
    let(:intake) { create :state_file_md_intake, primary_birth_date: dob }
    let(:dob) { Date.new((MultiTenantService.statefile.end_of_current_tax_year.year - 10), 1, 1) }

    it "doesn't include Jan 1st in the past tax year" do
      expect(intake.calculate_age(dob, inclusive_of_jan_1: true)).to eq 10
      expect(intake.calculate_age(dob, inclusive_of_jan_1: false)).to eq 10
    end
  end

  describe "#eligibility_filing_status" do
    subject(:intake) do
      create(:state_file_md_intake, eligibility_filing_status_mfj: :yes)
    end

    it "defines a correct enum" do
      expect(intake.eligibility_filing_status_mfj_before_type_cast).to eq(1)
      intake.update(eligibility_filing_status_mfj: :no)
      expect(intake.eligibility_filing_status_mfj_before_type_cast).to eq(2)
      intake.update(eligibility_filing_status_mfj: :unfilled)
      expect(intake.eligibility_filing_status_mfj_before_type_cast).to eq(0)
    end
  end

  describe "before_save" do
    context "when payment_or_deposit_type changes to mail" do
      let!(:intake) do
        create :state_file_md_intake,
               payment_or_deposit_type: "direct_deposit",
               account_type: "checking",
               bank_name: "Wells Fargo",
               routing_number: "123456789",
               account_number: "123",
               withdraw_amount: 123,
               date_electronic_withdrawal: Date.parse("April 1, 2023"),
               account_holder_name: "Neil Peart"
      end

      it "clears other account fields" do
        expect {
          intake.update(payment_or_deposit_type: "mail")
        }.to change(intake.reload, :account_type).to("unfilled")
                                                 .and change(intake.reload, :bank_name).to(nil)
                                                                                       .and change(intake.reload, :routing_number).to(nil).and change(intake.reload, :account_number).to(nil)
                                                                                                                                                                                     .and change(intake.reload, :withdraw_amount).to(nil)
                                                                                                                                                                                                                                 .and change(intake.reload, :date_electronic_withdrawal).to(nil)
                                                                                                                                                                                                                                                                                        .and change(intake.reload, :account_holder_name).to(nil)
      end
    end
  end

  describe "#has_dependent_without_health_insurance?" do
    let(:intake) { create(:state_file_md_intake) }

    context "when no dependents are present" do
      it "returns false" do
        expect(intake.has_dependent_without_health_insurance?).to eq(false)
      end
    end

    context "when dependents are present" do
      before do
        intake.dependents = dependents
      end

      context "when no dependents lack health insurance" do
        let(:dependents) do
          [
            create(:state_file_dependent, md_did_not_have_health_insurance: "no"),
            create(:state_file_dependent, md_did_not_have_health_insurance: "no")
          ]
        end

        it "returns false" do
          expect(intake.has_dependent_without_health_insurance?).to eq(false)
        end
      end

      context "when at least one dependent lacks health insurance" do
        let(:dependents) do
          [
            create(:state_file_dependent, md_did_not_have_health_insurance: "no"),
            create(:state_file_dependent, md_did_not_have_health_insurance: "yes")
          ]
        end

        it "returns true" do
          expect(intake.has_dependent_without_health_insurance?).to eq(true)
        end
      end
    end
  end
end
require 'rails_helper'

RSpec.describe StateFileMdIntake, type: :model do
  describe "#calculate_age" do
    let(:intake) { create :state_file_md_intake, primary_birth_date: dob }
    let(:dob) { Date.new((MultiTenantService.statefile.end_of_current_tax_year.year - 10), 1, 1) }

    it "doesn't include Jan 1st in the past tax year" do
      expect(intake.calculate_age(dob, inclusive_of_jan_1: true)).to eq 10
      expect(intake.calculate_age(dob, inclusive_of_jan_1: false)).to eq 10
    end
  end

  describe "#eligibility_filing_status" do
    subject(:intake) do
      create(:state_file_md_intake, eligibility_filing_status_mfj: :yes)
    end

    it "defines a correct enum" do
      expect(intake.eligibility_filing_status_mfj_before_type_cast).to eq(1)
      intake.update(eligibility_filing_status_mfj: :no)
      expect(intake.eligibility_filing_status_mfj_before_type_cast).to eq(2)
      intake.update(eligibility_filing_status_mfj: :unfilled)
      expect(intake.eligibility_filing_status_mfj_before_type_cast).to eq(0)
    end
  end

  describe "before_save" do
    context "when payment_or_deposit_type changes to mail" do
      let!(:intake) do
        create :state_file_md_intake,
               payment_or_deposit_type: "direct_deposit",
               account_type: "checking",
               bank_name: "Wells Fargo",
               routing_number: "123456789",
               account_number: "123",
               withdraw_amount: 123,
               date_electronic_withdrawal: Date.parse("April 1, 2023"),
               account_holder_name: "Neil Peart"
      end

      it "clears other account fields" do
        expect {
          intake.update(payment_or_deposit_type: "mail")
        }.to change(intake.reload, :account_type).to("unfilled")
                                                 .and change(intake.reload, :bank_name).to(nil)
                                                                                       .and change(intake.reload, :routing_number).to(nil).and change(intake.reload, :account_number).to(nil)
                                                                                                                                                                                     .and change(intake.reload, :withdraw_amount).to(nil)
                                                                                                                                                                                                                                 .and change(intake.reload, :date_electronic_withdrawal).to(nil)
                                                                                                                                                                                                                                                                                        .and change(intake.reload, :account_holder_name).to(nil)
      end
    end
  end

  describe "#has_dependent_without_health_insurance?" do
    let(:intake) { create(:state_file_md_intake) }

    context "when no dependents are present" do
      it "returns false" do
        expect(intake.has_dependent_without_health_insurance?).to eq(false)
      end
    end

    context "when dependents are present" do
      before do
        intake.dependents = dependents
      end

      context "when no dependents lack health insurance" do
        let(:dependents) do
          [
            create(:state_file_dependent, md_did_not_have_health_insurance: "no"),
            create(:state_file_dependent, md_did_not_have_health_insurance: "no")
          ]
        end

        it "returns false" do
          expect(intake.has_dependent_without_health_insurance?).to eq(false)
        end
      end

      context "when at least one dependent lacks health insurance" do
        let(:dependents) do
          [
            create(:state_file_dependent, md_did_not_have_health_insurance: "no"),
            create(:state_file_dependent, md_did_not_have_health_insurance: "yes")
          ]
        end

        it "returns true" do
          expect(intake.has_dependent_without_health_insurance?).to eq(true)
        end
      end
    end
  end
end
