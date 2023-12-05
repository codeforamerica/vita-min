# == Schema Information
#
# Table name: state_file_az_intakes
#
#  id                                    :bigint           not null, primary key
#  account_number                        :string
#  account_type                          :integer
#  armed_forces_member                   :integer          default("unfilled"), not null
#  armed_forces_wages                    :integer
#  bank_name                             :string
#  charitable_cash                       :integer          default(0)
#  charitable_contributions              :integer          default("unfilled"), not null
#  charitable_noncash                    :integer          default(0)
#  contact_preference                    :integer          default("unfilled"), not null
#  current_sign_in_at                    :datetime
#  current_sign_in_ip                    :inet
#  current_step                          :string
#  date_electronic_withdrawal            :date
#  eligibility_529_for_non_qual_expense  :integer          default("unfilled"), not null
#  eligibility_lived_in_state            :integer          default("unfilled"), not null
#  eligibility_married_filing_separately :integer          default("unfilled"), not null
#  eligibility_out_of_state_income       :integer          default("unfilled"), not null
#  email_address                         :citext
#  email_address_verified_at             :datetime
#  failed_attempts                       :integer          default(0), not null
#  has_prior_last_names                  :integer          default("unfilled"), not null
#  last_sign_in_at                       :datetime
#  last_sign_in_ip                       :inet
#  locked_at                             :datetime
#  payment_or_deposit_type               :integer          default("unfilled"), not null
#  phone_number                          :string
#  phone_number_verified_at              :datetime
#  primary_esigned                       :integer          default("unfilled"), not null
#  primary_esigned_at                    :datetime
#  primary_first_name                    :string
#  primary_last_name                     :string
#  primary_middle_initial                :string
#  prior_last_names                      :string
#  raw_direct_file_data                  :text
#  referrer                              :string
#  routing_number                        :string
#  sign_in_count                         :integer          default(0), not null
#  source                                :string
#  spouse_esigned                        :integer          default("unfilled"), not null
#  spouse_esigned_at                     :datetime
#  spouse_first_name                     :string
#  spouse_last_name                      :string
#  spouse_middle_initial                 :string
#  tribal_member                         :integer          default("unfilled"), not null
#  tribal_wages                          :integer
#  withdraw_amount                       :integer
#  created_at                            :datetime         not null
#  updated_at                            :datetime         not null
#  primary_state_id_id                   :bigint
#  spouse_state_id_id                    :bigint
#  visitor_id                            :string
#
# Indexes
#
#  index_state_file_az_intakes_on_primary_state_id_id  (primary_state_id_id)
#  index_state_file_az_intakes_on_spouse_state_id_id   (spouse_state_id_id)
#
require "rails_helper"

describe StateFileAzIntake do
  it_behaves_like :state_file_base_intake, factory: :state_file_az_intake

  describe "before_save" do
    context "when payment_or_deposit_type changes to mail" do
      let!(:intake) do
        create :state_file_ny_intake,
               payment_or_deposit_type: "direct_deposit",
               account_type: "checking",
               bank_name: "Wells Fargo",
               routing_number: "123456789",
               account_number: "123",
               withdraw_amount: 123,
               date_electronic_withdrawal: Date.parse("April 1, 2023")
      end

      it "clears other account fields" do
        expect {
          intake.update(payment_or_deposit_type: "mail")
        }.to change(intake.reload, :account_type).to("unfilled")
         .and change(intake.reload, :bank_name).to(nil)
         .and change(intake.reload, :routing_number).to(nil)
         .and change(intake.reload, :account_number).to(nil)
         .and change(intake.reload, :withdraw_amount).to(nil)
         .and change(intake.reload, :date_electronic_withdrawal).to(nil)
      end
    end

    context "when enum that has unfilled type is set to nil" do
      let(:intake) { create :state_file_az_intake, armed_forces_member: "yes", account_type: "checking", spouse_esigned_at: DateTime.now }
      it "saves as unfilled" do
        expect {
          intake.update(armed_forces_member: nil, account_type: nil, spouse_esigned_at: nil)
        }.to change(intake, :armed_forces_member).to("unfilled")
        .and change(intake, :account_type).to("unfilled")
        .and change(intake, :spouse_esigned_at).to(nil)
      end
    end
  end

  describe "#ask_spouse_name?" do
    context "when married filing jointly" do
      it "returns true" do
        intake = build(:state_file_az_intake, filing_status: "married_filing_jointly")
        expect(intake.ask_spouse_name?).to eq true
      end
    end

    context "when married filing separate" do
      it "returns false" do
        intake = build(:state_file_az_intake, filing_status: "married_filing_separately")
        expect(intake.ask_spouse_name?).to eq false
      end
    end
  end

  describe "#disqualifying_eligibility_answer" do
    it "returns nil when they haven't answered any questions yet" do
      intake = build(:state_file_az_intake)
      expect(intake.disqualifying_eligibility_answer).to be_nil
    end

    it "returns :eligibility_lived_in_state when they haven't been a resident the whole year" do
      intake = build(:state_file_az_intake, eligibility_lived_in_state: "no")
      expect(intake.disqualifying_eligibility_answer).to eq :eligibility_lived_in_state
    end

    it "returns :eligibility_married_filing_separately when they are married filing separately" do
      intake = build(:state_file_az_intake, eligibility_married_filing_separately: "yes")
      expect(intake.disqualifying_eligibility_answer).to eq :eligibility_married_filing_separately
    end

    it "returns :eligibility_out_of_state_income when they earned income in another state" do
      intake = build(:state_file_az_intake, eligibility_out_of_state_income: "yes")
      expect(intake.disqualifying_eligibility_answer).to eq :eligibility_out_of_state_income
    end

    it "returns :eligibility_529_for_non_qual_expense when they used a 529 withdrawal for a non qualifying expense" do
      intake = build(:state_file_az_intake, eligibility_529_for_non_qual_expense: "yes")
      expect(intake.disqualifying_eligibility_answer).to eq :eligibility_529_for_non_qual_expense
    end
  end

  describe "#has_disqualifying_eligibility_answer?" do
    it "returns false when they haven't answered any questions yet" do
      intake = build(:state_file_az_intake)
      expect(intake.has_disqualifying_eligibility_answer?).to eq false
    end

    it "returns true when they haven't been a resident the whole year" do
      intake = build(:state_file_az_intake, eligibility_lived_in_state: "no")
      expect(intake.has_disqualifying_eligibility_answer?).to eq true
    end

    it "returns true when they are married filing separately" do
      intake = build(:state_file_az_intake, eligibility_married_filing_separately: "yes")
      expect(intake.has_disqualifying_eligibility_answer?).to eq true
    end

    it "returns true when they earned income in another state" do
      intake = build(:state_file_az_intake, eligibility_out_of_state_income: "yes")
      expect(intake.has_disqualifying_eligibility_answer?).to eq true
    end

    it "returns true when they used a 529 withdrawal for a non qualifying expense" do
      intake = build(:state_file_az_intake, eligibility_529_for_non_qual_expense: "yes")
      expect(intake.has_disqualifying_eligibility_answer?).to eq true
    end
  end

  describe "#disqualifying_df_data_reason" do
    let(:intake) { create :state_file_az_intake }
    it "returns married_filing_separately when direct file data has a filing status of married filing separately" do
      intake.direct_file_data.filing_status = 3

      expect(intake.disqualifying_df_data_reason).to eq :married_filing_separately
    end

    it "returns nil when direct file data has no disqualifying fields" do
      expect(intake.disqualifying_df_data_reason).to be_nil
    end
  end
end
