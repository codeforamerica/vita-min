# == Schema Information
#
# Table name: state_file_az_intakes
#
#  id                                    :bigint           not null, primary key
#  armed_forces_member                   :integer          default("unfilled"), not null
#  armed_forces_wages                    :integer
#  bank_account_number                   :string
#  bank_account_type                     :integer
#  bank_routing_number                   :string
#  charitable_cash                       :integer          default(0)
#  charitable_contributions              :integer          default("unfilled"), not null
#  charitable_noncash                    :integer          default(0)
#  claimed_as_dep                        :integer          default("unfilled")
#  contact_preference                    :integer          default("unfilled"), not null
#  current_step                          :string
#  eligibility_529_for_non_qual_expense  :integer          default("unfilled"), not null
#  eligibility_lived_in_state            :integer          default("unfilled"), not null
#  eligibility_married_filing_separately :integer          default("unfilled"), not null
#  eligibility_out_of_state_income       :integer          default("unfilled"), not null
#  email_address                         :citext
#  email_address_verified_at             :datetime
#  has_prior_last_names                  :integer          default("unfilled"), not null
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
#  source                                :string
#  spouse_esigned                        :integer          default("unfilled"), not null
#  spouse_esigned_at                     :datetime
#  spouse_first_name                     :string
#  spouse_last_name                      :string
#  spouse_middle_initial                 :string
#  tribal_member                         :integer          default("unfilled"), not null
#  tribal_wages                          :integer
#  created_at                            :datetime         not null
#  updated_at                            :datetime         not null
#  visitor_id                            :string
#
require "rails_helper"

describe StateFileAzIntake do
  it_behaves_like :state_file_base_intake, factory: :state_file_az_intake

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
end
