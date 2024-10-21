require 'rails_helper'

RSpec.describe StateFileMdIntake, type: :model do
  describe "#calculate_age" do
    let(:intake) { create :state_file_md_intake, primary_birth_date: dob }
    let(:dob) { Date.new((MultiTenantService.statefile.end_of_current_tax_year.year - 10), 1, 1) }

    it "doesn't include Jan 1st in the past tax year" do
      expect(intake.calculate_age(inclusive_of_jan_1: true, dob: dob)).to eq 10
      expect(intake.calculate_age(inclusive_of_jan_1: false, dob: dob)).to eq 10
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
end
