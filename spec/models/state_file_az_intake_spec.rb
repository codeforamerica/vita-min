# == Schema Information
#
# Table name: state_file_az_intakes
#
#  id                                     :bigint           not null, primary key
#  account_number                         :string
#  account_type                           :integer
#  armed_forces_member                    :integer          default("unfilled"), not null
#  armed_forces_wages_amount              :decimal(12, 2)
#  charitable_cash_amount                 :decimal(12, 2)
#  charitable_contributions               :integer          default("unfilled"), not null
#  charitable_noncash_amount              :decimal(12, 2)
#  consented_to_sms_terms                 :integer          default("unfilled"), not null
#  consented_to_terms_and_conditions      :integer          default("unfilled"), not null
#  contact_preference                     :integer          default("unfilled"), not null
#  current_sign_in_at                     :datetime
#  current_sign_in_ip                     :inet
#  current_step                           :string
#  date_electronic_withdrawal             :date
#  df_data_import_succeeded_at            :datetime
#  df_data_imported_at                    :datetime
#  eligibility_529_for_non_qual_expense   :integer          default("unfilled"), not null
#  eligibility_lived_in_state             :integer          default("unfilled"), not null
#  eligibility_married_filing_separately  :integer          default("unfilled"), not null
#  eligibility_out_of_state_income        :integer          default("unfilled"), not null
#  email_address                          :citext
#  email_address_verified_at              :datetime
#  email_notification_opt_in              :integer          default("unfilled"), not null
#  extension_payments_amount              :decimal(12, 2)
#  failed_attempts                        :integer          default(0), not null
#  federal_return_status                  :string
#  has_prior_last_names                   :integer          default("unfilled"), not null
#  hashed_ssn                             :string
#  household_excise_credit_claimed        :integer          default("unfilled"), not null
#  household_excise_credit_claimed_amount :decimal(12, 2)
#  last_sign_in_at                        :datetime
#  last_sign_in_ip                        :inet
#  locale                                 :string           default("en")
#  locked_at                              :datetime
#  made_az321_contributions               :integer          default("unfilled"), not null
#  made_az322_contributions               :integer          default("unfilled"), not null
#  message_tracker                        :jsonb
#  paid_extension_payments                :integer          default("unfilled"), not null
#  paid_federal_extension_payments        :integer          default("unfilled"), not null
#  payment_or_deposit_type                :integer          default("unfilled"), not null
#  phone_number                           :string
#  phone_number_verified_at               :datetime
#  primary_birth_date                     :date
#  primary_esigned                        :integer          default("unfilled"), not null
#  primary_esigned_at                     :datetime
#  primary_first_name                     :string
#  primary_last_name                      :string
#  primary_middle_initial                 :string
#  primary_suffix                         :string
#  primary_was_incarcerated               :integer          default("unfilled"), not null
#  prior_last_names                       :string
#  raw_direct_file_data                   :text
#  raw_direct_file_intake_data            :jsonb
#  referrer                               :string
#  routing_number                         :string
#  sign_in_count                          :integer          default(0), not null
#  sms_notification_opt_in                :integer          default("unfilled"), not null
#  source                                 :string
#  spouse_birth_date                      :date
#  spouse_esigned                         :integer          default("unfilled"), not null
#  spouse_esigned_at                      :datetime
#  spouse_first_name                      :string
#  spouse_last_name                       :string
#  spouse_middle_initial                  :string
#  spouse_suffix                          :string
#  spouse_was_incarcerated                :integer          default("unfilled"), not null
#  tribal_member                          :integer          default("unfilled"), not null
#  tribal_wages_amount                    :decimal(12, 2)
#  unfinished_intake_ids                  :text             default([]), is an Array
#  unsubscribed_from_email                :boolean          default(FALSE), not null
#  was_incarcerated                       :integer          default("unfilled"), not null
#  withdraw_amount                        :integer
#  created_at                             :datetime         not null
#  updated_at                             :datetime         not null
#  federal_submission_id                  :string
#  primary_state_id_id                    :bigint
#  spouse_state_id_id                     :bigint
#  visitor_id                             :string
#
# Indexes
#
#  index_state_file_az_intakes_on_email_address        (email_address)
#  index_state_file_az_intakes_on_hashed_ssn           (hashed_ssn)
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
               routing_number: "123456789",
               account_number: "123",
               withdraw_amount: 123,
               date_electronic_withdrawal: Date.parse("April 1, #{Rails.configuration.statefile_current_tax_year}")
      end

      it "clears other account fields" do
        expect {
          intake.update(payment_or_deposit_type: "mail")
        }.to change(intake.reload, :account_type).to("unfilled")
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
        .and change(intake, :spouse_esigned_at).to(nil)
        expect(intake.account_type).to eq "unfilled"
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

  describe "#disqualified_from_excise_credit_fyst?" do
    let(:intake) { build(:state_file_az_intake) }
    let(:fake_df_data) { instance_double(DirectFileData) }
    before do
      allow(intake).to receive(:direct_file_data).and_return fake_df_data
      allow(fake_df_data).to receive(:claimed_as_dependent?).and_return false
    end

    # TODO: remove when old column is ignored
    context "has old column" do
      it "returns false if not incarcerated" do
        intake.update(was_incarcerated: "no")
        expect(intake.disqualified_from_excise_credit_fyst?).to eq false
      end

      it "returns true if incarcerated" do
        intake.update(was_incarcerated: "yes")
        expect(intake.disqualified_from_excise_credit_fyst?).to eq true
      end

      it "returns true if old incarcerated column filled out and credit claimed is yes" do
        intake.update(was_incarcerated: "no", household_excise_credit_claimed: "yes")
        expect(intake.disqualified_from_excise_credit_fyst?).to eq true
      end
    end

    context "has new columns" do
      before do
        intake.update(primary_was_incarcerated: "no", spouse_was_incarcerated: "no", household_excise_credit_claimed: "yes", household_excise_credit_claimed_amount: 50)
      end

      it "returns false if neither filer was incarcerated" do
        expect(intake.disqualified_from_excise_credit_fyst?).to eq false
      end

      it "returns false if only one filer incarcerated" do
        intake.update(primary_was_incarcerated: "no", spouse_was_incarcerated: "yes")
        expect(intake.disqualified_from_excise_credit_fyst?).to eq false
      end

      it "returns true if both filers were incarcerated" do
        intake.update(primary_was_incarcerated: "yes", spouse_was_incarcerated: "yes")
        expect(intake.disqualified_from_excise_credit_fyst?).to eq true
      end

      it "returns true if claimed as dependent" do
        allow(fake_df_data).to receive(:claimed_as_dependent?).and_return true
        expect(intake.disqualified_from_excise_credit_fyst?).to eq true
      end
    end
  end

  describe 'federal_dependent_counts' do
    let(:intake) { create :state_file_az_intake }

    it 'returns the correct dependents under 17' do
      create :state_file_dependent, intake: intake,
                                    dob: (MultiTenantService.statefile.end_of_current_tax_year - 10.years)
                                      .strftime("%Y-%m-%d")
      expect(intake.federal_dependent_count_under_17).to eq(1)
      expect(intake.federal_dependent_count_over_17_non_qualifying_senior).to eq(0)
      expect(intake.qualifying_parents_and_grandparents).to eq(0)
    end

    it 'returns the correct dependents over 17' do
      create :state_file_dependent, intake: intake,
                                    dob: (MultiTenantService.statefile.end_of_current_tax_year - 20.years)
                                      .strftime("%Y-%m-%d")
      expect(intake.federal_dependent_count_under_17).to eq(0)
      expect(intake.federal_dependent_count_over_17_non_qualifying_senior).to eq(1)
      expect(intake.qualifying_parents_and_grandparents).to eq(0)
    end

    it 'returns the correct senior dependents' do
      create :az_senior_dependent, intake: intake
      expect(intake.federal_dependent_count_under_17).to eq(0)
      expect(intake.federal_dependent_count_over_17_non_qualifying_senior).to eq(0)
      expect(intake.qualifying_parents_and_grandparents).to eq(1)
    end

    it 'returns correct qualifying and non-qualifying seniors' do
      create :az_senior_dependent_no_assistance, intake: intake
      create :az_senior_dependent, intake: intake
      expect(intake.federal_dependent_count_under_17).to eq(0)
      expect(intake.federal_dependent_count_over_17_non_qualifying_senior).to eq(1)
      expect(intake.qualifying_parents_and_grandparents).to eq(1)
    end
  end

  describe "disqualified_from_excise_credit_df?" do
    let(:intake) { create :state_file_az_intake }
    before do
      intake.direct_file_data.fed_agi = 10000
      intake.direct_file_data.primary_ssn = '123456789'
    end

    context "when fed agi is under limit for excise credit" do
      it "they are not disqualified" do
        intake.direct_file_data.fed_agi = 10000
        expect(intake).not_to be_disqualified_from_excise_credit_df
      end
    end

    context "when fed agi is over limit for excise credit" do
      it "they are disqualified" do
        intake.direct_file_data.fed_agi = 20000
        expect(intake).to be_disqualified_from_excise_credit_df
      end
    end

    context "when client does not have a valid SSN" do
      it "they are disqualified" do
        intake.direct_file_data.primary_ssn = '912555678'
        expect(intake).to be_disqualified_from_excise_credit_df
      end
    end

    context "when client has a valid SSN" do
      it "they are not disqualified" do
        intake.direct_file_data.primary_ssn = '123456789'
        expect(intake).not_to be_disqualified_from_excise_credit_df
      end
    end

    context "non-mfj filing status" do
      context "filer's SSN is valid for employment" do
        before do
          intake.direct_file_json_data.primary_filer.ssn_not_valid_for_employment = false
        end

        it "they are not disqualified" do
          expect(intake).not_to be_disqualified_from_excise_credit_df
        end
      end

      context "filer's SSN is not valid for employment" do
        before do
          intake.direct_file_json_data.primary_filer.ssn_not_valid_for_employment = true
        end

        it "they are disqualified" do
          expect(intake).to be_disqualified_from_excise_credit_df
        end
      end
    end

    context "mfj filing status" do
      let(:intake) { create :state_file_az_intake, :with_spouse }

      context "primary and spouse both have valid-for-employment SSNs" do
        before do
          allow(intake).to receive(:filing_status_mfj?).and_return(true)
          intake.direct_file_json_data.primary_filer.ssn_not_valid_for_employment = false
          intake.direct_file_json_data.spouse_filer.ssn_not_valid_for_employment = false
        end

        it "they are not disqualified" do
          expect(intake).not_to be_disqualified_from_excise_credit_df
        end
      end

      context "primary has valid-for-employment SSN but spouse does not" do
        before do
          allow(intake).to receive(:filing_status_mfj?).and_return(true)
          intake.direct_file_json_data.primary_filer.ssn_not_valid_for_employment = false
          intake.direct_file_json_data.spouse_filer.ssn_not_valid_for_employment = true
        end

        it "they are not disqualified" do
          expect(intake).not_to be_disqualified_from_excise_credit_df
        end
      end

      context "spouse has valid-for-employment SSN but primary does not" do
        before do
          allow(intake).to receive(:filing_status_mfj?).and_return(true)
          intake.direct_file_json_data.primary_filer.ssn_not_valid_for_employment = true
          intake.direct_file_json_data.spouse_filer.ssn_not_valid_for_employment = false
        end

        it "they are disqualified" do
          expect(intake).to be_disqualified_from_excise_credit_df
        end
      end

      context "neither primary nor spouse have valid-for-employment SSN" do
        before do
          allow(intake).to receive(:filing_status_mfj?).and_return(true)
          intake.direct_file_json_data.primary_filer.ssn_not_valid_for_employment = true
          intake.direct_file_json_data.spouse_filer.ssn_not_valid_for_employment = true
        end

        it "they are disqualified" do
          expect(intake).to be_disqualified_from_excise_credit_df
        end
      end
    end
  end

  describe "incarcerated_filer_count" do
    context "TEMPORARY, accepts old was_incarcerated_column" do
      it "returns 2 when yes and 0 when no" do
        expect(create(:state_file_az_intake, was_incarcerated: "yes").incarcerated_filer_count).to eq 2
        expect(create(:state_file_az_intake, was_incarcerated: "no").incarcerated_filer_count).to eq 0
      end
    end

    it "returns the number of filers who were incarcerated" do
      expect(create(:state_file_az_intake, primary_was_incarcerated: "no", spouse_was_incarcerated: "no").incarcerated_filer_count).to eq 0
      expect(create(:state_file_az_intake, primary_was_incarcerated: "yes", spouse_was_incarcerated: "no").incarcerated_filer_count).to eq 1
      expect(create(:state_file_az_intake, primary_was_incarcerated: "no", spouse_was_incarcerated: "yes").incarcerated_filer_count).to eq 1
      expect(create(:state_file_az_intake, primary_was_incarcerated: "yes", spouse_was_incarcerated: "yes").incarcerated_filer_count).to eq 2
    end
  end
end
