# == Schema Information
#
# Table name: state_file_nc_intakes
#
#  id                                :bigint           not null, primary key
#  account_number                    :string
#  account_type                      :integer          default("unfilled"), not null
#  bank_name                         :string
#  city                              :string
#  consented_to_terms_and_conditions :integer          default("unfilled"), not null
#  contact_preference                :integer          default("unfilled"), not null
#  current_sign_in_at                :datetime
#  current_sign_in_ip                :inet
#  current_step                      :string
#  date_electronic_withdrawal        :date
#  df_data_import_failed_at          :datetime
#  df_data_import_succeeded_at       :datetime
#  df_data_imported_at               :datetime
#  eligibility_lived_in_state        :integer          default("unfilled"), not null
#  eligibility_out_of_state_income   :integer          default("unfilled"), not null
#  eligibility_withdrew_529          :integer          default("unfilled"), not null
#  email_address                     :citext
#  email_address_verified_at         :datetime
#  failed_attempts                   :integer          default(0), not null
#  federal_return_status             :string
#  hashed_ssn                        :string
#  last_sign_in_at                   :datetime
#  last_sign_in_ip                   :inet
#  locale                            :string           default("en")
#  locked_at                         :datetime
#  message_tracker                   :jsonb
#  payment_or_deposit_type           :integer          default("unfilled"), not null
#  phone_number                      :string
#  phone_number_verified_at          :datetime
#  primary_birth_date                :date
#  primary_esigned                   :integer          default("unfilled"), not null
#  primary_esigned_at                :datetime
#  primary_first_name                :string
#  primary_last_name                 :string
#  primary_middle_initial            :string
#  primary_suffix                    :string
#  primary_veteran                   :integer          default("unfilled"), not null
#  raw_direct_file_data              :text
#  raw_direct_file_intake_data       :jsonb
#  referrer                          :string
#  residence_county                  :string
#  routing_number                    :string
#  sales_use_tax                     :decimal(12, 2)
#  sales_use_tax_calculation_method  :integer          default("unfilled"), not null
#  sign_in_count                     :integer          default(0), not null
#  source                            :string
#  spouse_birth_date                 :date
#  spouse_esigned                    :integer          default("unfilled"), not null
#  spouse_esigned_at                 :datetime
#  spouse_first_name                 :string
#  spouse_last_name                  :string
#  spouse_middle_initial             :string
#  spouse_suffix                     :string
#  spouse_veteran                    :integer          default("unfilled"), not null
#  ssn                               :string
#  street_address                    :string
#  tribal_member                     :integer          default("unfilled"), not null
#  tribal_wages_amount               :decimal(12, 2)
#  unsubscribed_from_email           :boolean          default(FALSE), not null
#  untaxed_out_of_state_purchases    :integer          default("unfilled"), not null
#  withdraw_amount                   :integer
#  zip_code                          :string
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  federal_submission_id             :string
#  primary_state_id_id               :bigint
#  spouse_state_id_id                :bigint
#  visitor_id                        :string
#
# Indexes
#
#  index_state_file_nc_intakes_on_hashed_ssn           (hashed_ssn)
#  index_state_file_nc_intakes_on_primary_state_id_id  (primary_state_id_id)
#  index_state_file_nc_intakes_on_spouse_state_id_id   (spouse_state_id_id)
#
require 'rails_helper'

RSpec.describe StateFileNcIntake, type: :model do
  it_behaves_like :state_file_base_intake, factory: :state_file_nc_intake

  describe "#calculate_sales_use_tax" do
    let(:intake) { create :state_file_nc_intake }
    it "calculates the sales use tax using the nc_taxable_income" do
      allow(intake.calculator.lines).to receive(:[]).with(:NCD400_LINE_14).and_return(double(value: 2500))
      expect(intake.calculate_sales_use_tax).to eq 2
    end
  end

  describe "date_electronic_withdrawal validations" do
    let(:electronic_withdrawal_date) { nil }
    let!(:intake) { build :state_file_nc_intake, date_electronic_withdrawal: electronic_withdrawal_date }
    let(:fake_time) { Time.new(2024, 11, 25) }

    before do
      Timecop.freeze(fake_time)
    end

    after do
      Timecop.return
    end

    context "when there is not withdrawal date" do
      it "is valid" do
        expect(intake).to be_valid
      end
    end

    context "when the withdrawal date is in the future, on a weekday and not on a holiday" do
      let(:electronic_withdrawal_date) { fake_time.to_date + 1.day }
      it "is valid and saves to intake" do
        expect(intake).to be_valid
        intake.save!
        expect(intake.reload.date_electronic_withdrawal).to eq electronic_withdrawal_date
      end
    end

    context "when the date is in the past" do
      let(:electronic_withdrawal_date) { fake_time.to_date - 1.day }
      it "fails to save the intake" do
        expect(intake).not_to be_valid
      end
    end

    context "when the date is the current date" do
      let(:electronic_withdrawal_date) { fake_time.to_date }
      it "fails to save the intake" do
        expect(intake).not_to be_valid
      end
    end

    context "when the date is a weekend day" do
      let(:fake_time) { (electronic_withdrawal_date - 2.days).to_time }
      let(:electronic_withdrawal_date) { Date.new(2024, 11, 23) } # Saturday
      it "fails to save the intake" do
        expect(intake).not_to be_valid
      end
    end

    context "when the date is a federal holiday occurring on any day except Sunday" do
      let(:fake_time) { (electronic_withdrawal_date - 2.days).to_time }
      let(:electronic_withdrawal_date) { Date.parse("January 1st, 2024") }
      it "fails to save the intake" do
        expect(intake).not_to be_valid
      end
    end

    context "when the date is after a federal holiday occurring on a Sunday" do
      let(:fake_time) { (electronic_withdrawal_date - 2.days).to_time }
      let(:electronic_withdrawal_date) { Date.parse("January 2nd, 2023") }
      it "fails to save the intake" do
        expect(intake).not_to be_valid
      end
    end
  end
end
