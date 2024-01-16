# == Schema Information
#
# Table name: intakes
#
#  id                                                   :bigint           not null, primary key
#  additional_info                                      :string
#  adopted_child                                        :integer          default(0), not null
#  advance_ctc_amount_received                          :integer
#  advance_ctc_entry_method                             :integer          default(0), not null
#  already_applied_for_stimulus                         :integer          default(0), not null
#  already_filed                                        :integer          default("unfilled"), not null
#  balance_pay_from_bank                                :integer          default(0), not null
#  bank_account_number                                  :text
#  bank_account_type                                    :integer          default("unfilled"), not null
#  bank_name                                            :string
#  bank_routing_number                                  :string
#  bought_employer_health_insurance                     :integer          default(0), not null
#  bought_energy_efficient_items                        :integer
#  bought_marketplace_health_insurance                  :integer          default(0), not null
#  cannot_claim_me_as_a_dependent                       :integer          default(0), not null
#  canonical_email_address                              :string
#  city                                                 :string
#  claim_eitc                                           :integer          default(0), not null
#  claim_owed_stimulus_money                            :integer          default("unfilled"), not null
#  claimed_by_another                                   :integer          default(0), not null
#  completed_at                                         :datetime
#  completed_yes_no_questions_at                        :datetime
#  consented_to_legal                                   :integer          default(0), not null
#  continued_at_capacity                                :boolean          default(FALSE)
#  contributed_to_401k                                  :integer          default(0), not null
#  contributed_to_ira                                   :integer          default(0), not null
#  contributed_to_other_retirement_account              :integer          default(0), not null
#  contributed_to_roth_ira                              :integer          default(0), not null
#  current_step                                         :string
#  demographic_disability                               :integer          default(0), not null
#  demographic_english_conversation                     :integer          default(0), not null
#  demographic_english_reading                          :integer          default(0), not null
#  demographic_primary_american_indian_alaska_native    :boolean
#  demographic_primary_asian                            :boolean
#  demographic_primary_black_african_american           :boolean
#  demographic_primary_ethnicity                        :integer          default(0), not null
#  demographic_primary_native_hawaiian_pacific_islander :boolean
#  demographic_primary_prefer_not_to_answer_race        :boolean
#  demographic_primary_white                            :boolean
#  demographic_questions_hub_edit                       :boolean          default(FALSE)
#  demographic_questions_opt_in                         :integer          default(0), not null
#  demographic_spouse_american_indian_alaska_native     :boolean
#  demographic_spouse_asian                             :boolean
#  demographic_spouse_black_african_american            :boolean
#  demographic_spouse_ethnicity                         :integer          default(0), not null
#  demographic_spouse_native_hawaiian_pacific_islander  :boolean
#  demographic_spouse_prefer_not_to_answer_race         :boolean
#  demographic_spouse_white                             :boolean
#  demographic_veteran                                  :integer          default(0), not null
#  disallowed_ctc                                       :boolean
#  divorced                                             :integer          default(0), not null
#  divorced_year                                        :string
#  eip1_amount_received                                 :integer
#  eip1_and_2_amount_received_confidence                :integer
#  eip1_entry_method                                    :integer          default(0), not null
#  eip2_amount_received                                 :integer
#  eip2_entry_method                                    :integer          default(0), not null
#  eip3_amount_received                                 :integer
#  eip3_entry_method                                    :integer          default(0), not null
#  eip_only                                             :boolean
#  email_address                                        :citext
#  email_address_verified_at                            :datetime
#  email_domain                                         :string
#  email_notification_opt_in                            :integer          default("unfilled"), not null
#  ever_married                                         :integer          default(0), not null
#  ever_owned_home                                      :integer          default(0), not null
#  exceeded_investment_income_limit                     :integer          default(0)
#  feedback                                             :string
#  feeling_about_taxes                                  :integer          default(0), not null
#  filed_2020                                           :integer          default(0), not null
#  filed_prior_tax_year                                 :integer          default(0), not null
#  filing_for_stimulus                                  :integer          default(0), not null
#  filing_joint                                         :integer          default(0), not null
#  final_info                                           :string
#  former_foster_youth                                  :integer          default(0), not null
#  full_time_student_less_than_five_months              :integer          default(0), not null
#  got_married_during_tax_year                          :integer          default(0), not null
#  had_asset_sale_income                                :integer          default(0), not null
#  had_capital_loss_carryover                           :integer          default(0), not null
#  had_cash_check_digital_assets                        :integer          default(0), not null
#  had_debt_forgiven                                    :integer          default(0), not null
#  had_dependents                                       :integer          default(0), not null
#  had_disability                                       :integer          default(0), not null
#  had_disability_income                                :integer          default(0), not null
#  had_disaster_loss                                    :integer          default(0), not null
#  had_disaster_loss_where                              :string
#  had_disqualifying_non_w2_income                      :integer
#  had_farm_income                                      :integer          default(0), not null
#  had_gambling_income                                  :integer          default(0), not null
#  had_hsa                                              :integer          default(0), not null
#  had_interest_income                                  :integer          default(0), not null
#  had_local_tax_refund                                 :integer          default(0), not null
#  had_medicaid_medicare                                :integer          default(0), not null
#  had_other_income                                     :integer          default(0), not null
#  had_rental_income                                    :integer          default(0), not null
#  had_retirement_income                                :integer          default(0), not null
#  had_scholarships                                     :integer          default(0), not null
#  had_self_employment_income                           :integer          default(0), not null
#  had_social_security_income                           :integer          default(0), not null
#  had_social_security_or_retirement                    :integer          default(0), not null
#  had_tax_credit_disallowed                            :integer          default(0), not null
#  had_tips                                             :integer          default(0), not null
#  had_unemployment_income                              :integer          default(0), not null
#  had_w2s                                              :integer          default(0), not null
#  had_wages                                            :integer          default(0), not null
#  has_crypto_income                                    :boolean          default(FALSE)
#  has_primary_ip_pin                                   :integer          default(0), not null
#  has_spouse_ip_pin                                    :integer          default(0), not null
#  has_ssn_of_alimony_recipient                         :integer          default(0), not null
#  hashed_primary_ssn                                   :string
#  hashed_spouse_ssn                                    :string
#  home_location                                        :integer
#  homeless_youth                                       :integer          default(0), not null
#  income_over_limit                                    :integer          default(0), not null
#  interview_timing_preference                          :string
#  irs_language_preference                              :integer
#  issued_identity_pin                                  :integer          default(0), not null
#  job_count                                            :integer
#  lived_with_spouse                                    :integer          default(0), not null
#  locale                                               :string
#  made_estimated_tax_payments                          :integer          default(0), not null
#  made_estimated_tax_payments_amount                   :decimal(12, 2)
#  married                                              :integer          default(0), not null
#  multiple_states                                      :integer          default(0), not null
#  navigator_has_verified_client_identity               :boolean
#  navigator_name                                       :string
#  need_itin_help                                       :integer          default(0), not null
#  needs_help_2016                                      :integer          default(0), not null
#  needs_help_2018                                      :integer          default(0), not null
#  needs_help_2019                                      :integer          default(0), not null
#  needs_help_2020                                      :integer          default(0), not null
#  needs_help_2021                                      :integer          default(0), not null
#  needs_help_2022                                      :integer          default(0), not null
#  needs_help_current_year                              :integer          default(0), not null
#  needs_help_previous_year_1                           :integer          default(0), not null
#  needs_help_previous_year_2                           :integer          default(0), not null
#  needs_help_previous_year_3                           :integer          default(0), not null
#  needs_to_flush_searchable_data_set_at                :datetime
#  no_eligibility_checks_apply                          :integer          default(0), not null
#  no_ssn                                               :integer          default(0), not null
#  not_full_time_student                                :integer          default(0), not null
#  other_income_types                                   :string
#  paid_alimony                                         :integer          default(0), not null
#  paid_charitable_contributions                        :integer          default(0), not null
#  paid_dependent_care                                  :integer          default(0), not null
#  paid_local_tax                                       :integer          default(0), not null
#  paid_medical_expenses                                :integer          default(0), not null
#  paid_mortgage_interest                               :integer          default(0), not null
#  paid_post_secondary_educational_expenses             :integer          default(0), not null
#  paid_retirement_contributions                        :integer          default(0), not null
#  paid_school_supplies                                 :integer          default(0), not null
#  paid_self_employment_expenses                        :integer          default(0), not null
#  paid_student_loan_interest                           :integer          default(0), not null
#  phone_carrier                                        :string
#  phone_number                                         :string
#  phone_number_can_receive_texts                       :integer          default(0), not null
#  phone_number_type                                    :string
#  preferred_interview_language                         :string
#  preferred_name                                       :string
#  preferred_written_language                           :string
#  presidential_campaign_fund_donation                  :integer          default(0), not null
#  primary_active_armed_forces                          :integer          default(0), not null
#  primary_birth_date                                   :date
#  primary_consented_to_service                         :integer          default("unfilled"), not null
#  primary_consented_to_service_ip                      :inet
#  primary_first_name                                   :string
#  primary_ip_pin                                       :text
#  primary_job_title                                    :string
#  primary_last_four_ssn                                :text
#  primary_last_name                                    :string
#  primary_middle_initial                               :string
#  primary_prior_year_agi_amount                        :integer
#  primary_prior_year_signature_pin                     :string
#  primary_signature_pin                                :text
#  primary_signature_pin_at                             :datetime
#  primary_ssn                                          :text
#  primary_suffix                                       :string
#  primary_tin_type                                     :integer
#  primary_us_citizen                                   :integer          default(0), not null
#  product_year                                         :integer          not null
#  receive_written_communication                        :integer          default(0), not null
#  received_advance_ctc_payment                         :integer
#  received_alimony                                     :integer          default(0), not null
#  received_homebuyer_credit                            :integer          default(0), not null
#  received_irs_letter                                  :integer          default(0), not null
#  received_stimulus_payment                            :integer          default(0), not null
#  referrer                                             :string
#  refund_payment_method                                :integer          default("unfilled"), not null
#  register_to_vote                                     :integer          default(0), not null
#  reported_asset_sale_loss                             :integer          default(0), not null
#  reported_self_employment_loss                        :integer          default(0), not null
#  requested_docs_token                                 :string
#  requested_docs_token_created_at                      :datetime
#  routed_at                                            :datetime
#  routing_criteria                                     :string
#  routing_value                                        :string
#  satisfaction_face                                    :integer          default(0), not null
#  savings_purchase_bond                                :integer          default(0), not null
#  savings_split_refund                                 :integer          default(0), not null
#  searchable_data                                      :tsvector
#  separated                                            :integer          default(0), not null
#  separated_year                                       :string
#  signature_method                                     :integer          default("online"), not null
#  sms_notification_opt_in                              :integer          default("unfilled"), not null
#  sms_phone_number                                     :string
#  sms_phone_number_verified_at                         :datetime
#  sold_a_home                                          :integer          default(0), not null
#  sold_assets                                          :integer          default(0), not null
#  source                                               :string
#  spouse_active_armed_forces                           :integer          default(0)
#  spouse_auth_token                                    :string
#  spouse_birth_date                                    :date
#  spouse_consented_to_service                          :integer          default(0), not null
#  spouse_consented_to_service_at                       :datetime
#  spouse_consented_to_service_ip                       :inet
#  spouse_email_address                                 :citext
#  spouse_filed_prior_tax_year                          :integer          default(0), not null
#  spouse_first_name                                    :string
#  spouse_had_disability                                :integer          default(0), not null
#  spouse_ip_pin                                        :text
#  spouse_issued_identity_pin                           :integer          default(0), not null
#  spouse_job_title                                     :string
#  spouse_last_four_ssn                                 :text
#  spouse_last_name                                     :string
#  spouse_middle_initial                                :string
#  spouse_phone_number                                  :string
#  spouse_prior_year_agi_amount                         :integer
#  spouse_prior_year_signature_pin                      :string
#  spouse_signature_pin                                 :text
#  spouse_signature_pin_at                              :datetime
#  spouse_ssn                                           :text
#  spouse_suffix                                        :string
#  spouse_tin_type                                      :integer
#  spouse_us_citizen                                    :integer          default(0), not null
#  spouse_was_blind                                     :integer          default(0), not null
#  spouse_was_full_time_student                         :integer          default(0), not null
#  state                                                :string
#  state_of_residence                                   :string
#  street_address                                       :string
#  street_address2                                      :string
#  tax_credit_disallowed_year                           :integer
#  timezone                                             :string
#  triage_filing_frequency                              :integer          default(0), not null
#  triage_filing_status                                 :integer          default(0), not null
#  triage_income_level                                  :integer          default(0), not null
#  triage_vita_income_ineligible                        :integer          default(0), not null
#  type                                                 :string
#  urbanization                                         :string
#  use_primary_name_for_name_control                    :boolean          default(FALSE)
#  used_itin_certifying_acceptance_agent                :boolean          default(FALSE), not null
#  usps_address_late_verification_attempts              :integer          default(0)
#  usps_address_verified_at                             :datetime
#  viewed_at_capacity                                   :boolean          default(FALSE)
#  wants_to_itemize                                     :integer          default(0), not null
#  was_blind                                            :integer          default(0), not null
#  was_full_time_student                                :integer          default(0), not null
#  widowed                                              :integer          default(0), not null
#  widowed_year                                         :string
#  with_general_navigator                               :boolean          default(FALSE)
#  with_incarcerated_navigator                          :boolean          default(FALSE)
#  with_limited_english_navigator                       :boolean          default(FALSE)
#  with_unhoused_navigator                              :boolean          default(FALSE)
#  zip_code                                             :string
#  created_at                                           :datetime         not null
#  updated_at                                           :datetime         not null
#  client_id                                            :bigint
#  matching_previous_year_intake_id                     :bigint
#  primary_drivers_license_id                           :bigint
#  spouse_drivers_license_id                            :bigint
#  visitor_id                                           :string
#  vita_partner_id                                      :bigint
#  with_drivers_license_photo_id                        :boolean          default(FALSE)
#  with_itin_taxpayer_id                                :boolean          default(FALSE)
#  with_other_state_photo_id                            :boolean          default(FALSE)
#  with_passport_photo_id                               :boolean          default(FALSE)
#  with_social_security_taxpayer_id                     :boolean          default(FALSE)
#  with_vita_approved_photo_id                          :boolean          default(FALSE)
#  with_vita_approved_taxpayer_id                       :boolean          default(FALSE)
#
# Indexes
#
#  index_intakes_on_canonical_email_address                (canonical_email_address)
#  index_intakes_on_client_id                              (client_id)
#  index_intakes_on_completed_at                           (completed_at) WHERE (completed_at IS NOT NULL)
#  index_intakes_on_email_address                          (email_address)
#  index_intakes_on_email_domain                           (email_domain)
#  index_intakes_on_hashed_primary_ssn                     (hashed_primary_ssn)
#  index_intakes_on_matching_previous_year_intake_id       (matching_previous_year_intake_id)
#  index_intakes_on_needs_to_flush_searchable_data_set_at  (needs_to_flush_searchable_data_set_at) WHERE (needs_to_flush_searchable_data_set_at IS NOT NULL)
#  index_intakes_on_phone_number                           (phone_number)
#  index_intakes_on_primary_consented_to_service           (primary_consented_to_service)
#  index_intakes_on_primary_drivers_license_id             (primary_drivers_license_id)
#  index_intakes_on_searchable_data                        (searchable_data) USING gin
#  index_intakes_on_sms_phone_number                       (sms_phone_number)
#  index_intakes_on_spouse_drivers_license_id              (spouse_drivers_license_id)
#  index_intakes_on_spouse_email_address                   (spouse_email_address)
#  index_intakes_on_type                                   (type)
#  index_intakes_on_vita_partner_id                        (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (matching_previous_year_intake_id => intakes.id)
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#

require "rails_helper"

describe Intake do
  describe "validations" do
    context "with an invalid email" do
      let(:intake) { build(:intake, email_address: "someone@example .com") }

      it "is not valid and adds an error to the email" do
        expect(intake).not_to be_valid
        expect(intake.errors).to include :email_address
      end
    end

    context "phone_number & sms_phone_number" do
      let(:intake) { build :intake, phone_number: input_number, sms_phone_number: input_number }
      before { intake.valid? }

      context "with e164" do
        let(:input_number) { "+15005550006" }
        it "is valid" do
          expect(intake.errors).not_to include :phone_number
          expect(intake.errors).not_to include :sms_phone_number
        end
      end

      context "without a + but otherwise correct" do
        let(:input_number) { "15005550006" }
        it "is not valid" do
          expect(intake.errors).to include :phone_number
          expect(intake.errors).to include :sms_phone_number
        end
      end

      context "without a +1 but otherwise correct" do
        let(:input_number) { "5005550006" }

        it "is not valid" do
          expect(intake.errors).to include :phone_number
          expect(intake.errors).to include :sms_phone_number
        end
      end

      context "with any non-numeric characters" do
        let(:input_number) { "+1500555-006" }

        it "is not valid" do
          expect(intake.errors).to include :phone_number
          expect(intake.errors).to include :sms_phone_number
        end
      end
    end

    context "mandatory fields" do
      it "requires visitor_id and product_year" do
        expect(Intake.new).not_to be_valid
        expect(Intake.new(visitor_id: "present", product_year: 2022)).to be_valid
      end
    end
  end

  describe "keeping last 4 ssn and hashed primary ssn in sync with ssn" do
    context "when creating the object" do
      let(:intake) { create :intake, primary_ssn: "12345678", spouse_ssn: "234567777" }

      it "updates last_four values when setting" do
        expect(intake.primary_last_four_ssn).to eq "5678"
        expect(intake.spouse_last_four_ssn).to eq "7777"
      end

      it "updates the hashed primary ssn when setting" do
        expect(intake.hashed_primary_ssn).to eq DeduplicationService.sensitive_attribute_hashed(intake, :primary_ssn)
      end
    end

    context "primary_ssn" do
      let!(:intake) { create :intake, primary_ssn: "12345678", spouse_ssn: "2345677777" }

      context "when removing primary_ssn" do
        it "sets primary_last_four_ssn and hashed_primary_ssn to nil" do
          expect{
            intake.update(primary_ssn: nil)
          }.to change(intake, :primary_last_four_ssn).to(nil)
           .and change(intake, :hashed_primary_ssn).to(nil)
        end
      end

      context "when setting primary_ssn to an empty string" do
        it "sets primary_last_four_ssn to an empty string and hashed primary ssn to nil" do
          expect{
            intake.update(primary_ssn: "")
          }.to change(intake, :primary_last_four_ssn).to("")
           .and change(intake, :hashed_primary_ssn).to(nil)
        end
      end

      context "when changing primary_ssn" do
        let(:hashed_ssn) { DeduplicationService.sensitive_attribute_hashed((create :intake, primary_ssn: "123456666"), :primary_ssn) }

        it "sets primary_last_four_ssn to a new value" do
          expect{
            intake.update(primary_ssn: "123456666")
          }.to change(intake, :primary_last_four_ssn).to("6666")
           .and change(intake.reload, :hashed_primary_ssn).to(hashed_ssn)
        end
      end
    end

    context "spouse_ssn" do
      let!(:intake) { create :intake, primary_ssn: "12345678", spouse_ssn: "2345677777" }

      context "when removing spouse_ssn" do
        it "sets spouse_last_four_ssn to nil" do
          expect{
            intake.update(spouse_ssn: nil)
          }.to change(intake, :spouse_last_four_ssn).to(nil)
        end
      end

      context "when setting spouse_ssn to an empty string" do
        it "sets spouse_last_four_ssn to an empty string" do
          expect{
            intake.update(spouse_ssn: "")
          }.to change(intake, :spouse_last_four_ssn).to("")
        end
      end

      context "when changing spouse_ssn" do
        let(:hashed_ssn) { DeduplicationService.sensitive_attribute_hashed((create :intake, spouse_ssn: "123456666"), :spouse_ssn) }

        it "sets spouse_last_four_ssn to a new value" do
          expect{
            intake.update(spouse_ssn: "123456666")
          }.to change(intake, :spouse_last_four_ssn).to("6666")
           .and change(intake.reload, :hashed_spouse_ssn).to(hashed_ssn)
        end
      end
    end

  end

  let(:required_fields) { { visitor_id: "visitor_id", product_year: 2022 } }

  describe "canonical_email_address" do
    it "is persisted when the intake is saved" do
      example_intake = Intake.create!(email_address: "a.REAL.email@example.com", **required_fields)
      expect(example_intake.canonical_email_address).to eq('a.real.email@example.com')

      gmail_intake = Intake.create!(email_address: "a.REAL.email@gmail.com", **required_fields)
      expect(gmail_intake.canonical_email_address).to eq('arealemail@gmail.com')
    end
  end

  describe "email_address" do
    it "searches case-insensitively" do
      intake = Intake.create!(email_address: "eXample@EXAMPLE.COM", **required_fields)
      expect(Intake.where(email_address: "example@example.com")).to include(intake)
    end
  end

  describe "email_domain" do
    it "is persisted when the intake is saved" do
      example_intake = Intake.create!(email_address: "a.REAL.email@example.com", **required_fields)
      expect(example_intake.email_domain).to eq('example.com')

      gmail_intake = Intake.create!(email_address: "a.REAL.email@gmail.com", **required_fields)
      expect(gmail_intake.email_domain).to eq('gmail.com')
    end
  end

  describe "spouse_email_address" do
    it "searches case-insensitively" do
      intake = Intake.create!(spouse_email_address: "eXample@EXAMPLE.COM", **required_fields)
      expect(Intake.where(spouse_email_address: "example@example.com")).to include(intake)
    end
  end

  describe ".search" do
    context "with some clients" do
      let(:client) { create :client, id: 222 }
      let(:other_client) { create :client, id: 333 }
      let!(:intake) { create :intake, id: 444, client: client, primary_first_name: "Jeremy", primary_last_name: "Fisher", preferred_name: "Jerry", spouse_first_name: "Jenny", spouse_last_name: "Fishy", email_address: "jerry@example.com", sms_phone_number: "+15005550006", phone_number: "+15005550007" }
      let!(:other_intake) { create :intake, id: 555, client: other_client, primary_first_name: "Geoffrey", primary_last_name: "Foster", preferred_name: "Jeff", spouse_first_name: "Jennifer", spouse_last_name: "Frosty", email_address: "jeff@example.com", sms_phone_number: "+15005550008", phone_number: "+15005550009" }

      before do
        SearchIndexer.refresh_search_index
      end

      it "can match on each required field" do
        expect(described_class.search("222")).to eq [intake] # client_id
        expect(described_class.search("jeremy")).to eq [intake] # primary_first_name
        expect(described_class.search("fisher")).to eq [intake] # primary_last_name
        expect(described_class.search("jerry")).to eq [intake] # preferred_name
        expect(described_class.search("jenny")).to eq [intake] # spouse_first_name
        expect(described_class.search("fishy")).to eq [intake] # spouse_last_name
        expect(described_class.search("jerry@example.com")).to eq [intake] # email_address
        expect(described_class.search("+15005550006")).to eq [intake] # sms_phone_number
        expect(described_class.search("+15005550007")).to eq [intake] # phone_number
      end

      it "can do a partial match for the beginning of a field" do
        expect(described_class.search("jerr")).to eq [intake]
      end

      it "can do a match on two fields in the same search" do
        expect(described_class.search("jerry fisher")).to eq [intake]
      end

      it "cannot do partial matches for the latter portion of a field" do
        # including this test as documentation, we want to change this behavior in the future
        expect(described_class.search("y@example.com")).to eq []
        expect(described_class.search("5005550007")).to eq []
      end

      it "cannot match on a formatted phone number" do
        # including this test as documentation, we want to change this behavior in the future
        expect(described_class.search("(500)555-0007")).to eq []
      end
    end
  end

  describe ".completed_yes_no_questions" do
    let!(:included_intake) { create :intake, completed_yes_no_questions_at: DateTime.now }
    let!(:excluded_intake) { create :intake, completed_yes_no_questions_at: nil }

    it "returns intakes with a non-nil completed_yes_no_questions_at value" do
      expect(described_class.completed_yes_no_questions).to match_array [included_intake]
    end
  end

  describe "#irs_language_preference_code" do
    context "when language is english" do
      let(:intake) { build :intake, irs_language_preference: "english" }

      it "responds with 000" do
        expect(intake.irs_language_preference_code).to eq "000"
      end
    end

    context "when language is english" do
      let(:intake) { build :intake, irs_language_preference: "spanish" }

      it "responds with 001" do
        expect(intake.irs_language_preference_code).to eq "001"
      end
    end

    context "when language is nil" do
      let(:intake) { build :intake, irs_language_preference: nil }

      it "responds with nil" do
        expect(intake.irs_language_preference_code).to eq nil

      end
    end
  end

  describe "#referrer_domain" do
    let(:intake) { build :intake, referrer: referrer }

    context "with a referrer" do
      let(:referrer) { "https://www.google.com/some/stuffs?id=whocares" }

      it "returns the domain from the referrer" do
        expect(intake.referrer_domain).to eq "www.google.com"
      end
    end

    context "with no referrer" do
      let(:referrer) { nil }

      it "returns the domain from the referrer" do
        expect(intake.referrer_domain).to be_nil
      end
    end
  end

  describe "#any_students?" do
    context "without answers" do
      let(:intake) { build :intake }

      it "returns false" do
        expect(intake.any_students?).to eq false
      end
    end

    context "when the primary user says they are not a student" do
      let(:intake) do
        build :intake, was_full_time_student: "no"
      end

      it "returns false" do
        expect(intake.any_students?).to eq false
      end
    end

    context "when the primary user says they are a full time student" do
      let(:intake) do
        build :intake, was_full_time_student: "yes", spouse_was_full_time_student: "no"
      end

      it "returns true" do
        expect(intake.any_students?).to eq true
      end
    end

    context "when a dependent is marked as a student" do
      let(:intake) { create :intake }
      before { create :dependent, intake: intake, was_student: "yes" }

      it "returns true" do
        expect(intake.any_students?).to eq true
      end
    end

    context "when they said someone was a student" do
      let(:intake) { create :intake, was_full_time_student: "yes" }

      it "returns true" do
        expect(intake.any_students?).to eq true
      end
    end
  end

  describe "#get_or_create_spouse_auth_token" do
    let(:intake) { build :intake, spouse_auth_token: existing_token }
    let(:new_token) { "n3wt0k3n" }
    before do
      allow(SecureRandom).to receive(:urlsafe_base64).with(8).and_return(new_token)
    end

    context "when a spouse auth token does not yet exist" do
      let(:existing_token) { nil }

      it "generates the token and returns it" do
        result = intake.get_or_create_spouse_auth_token
        expect(result).to eq new_token
        expect(intake.spouse_auth_token).to eq new_token
        expect(SecureRandom).to have_received(:urlsafe_base64).with(8)
      end
    end

    context "when the token already exists" do
      let(:existing_token) { "3x1st1ngT0k3n" }

      it "just returns the token and does not generate a new one" do
        result = intake.get_or_create_spouse_auth_token
        expect(result).to eq existing_token
        expect(intake.spouse_auth_token).to eq existing_token
        expect(SecureRandom).not_to have_received(:urlsafe_base64)
      end
    end
  end

  describe "#filing_years" do
    let(:intake) { build :intake }
    let!(:client) { create :client, tax_returns: [], intake: intake }
    let(:tax_returns) { [] }

    context "with unfilled filing years" do
      it "returns empty array" do
        expect(intake.filing_years).to eq([])
      end
    end

    context "with a couple filing years selected" do
      let!(:client) { create :client, tax_returns: [
        build(:tax_return, year: 2021),
        build(:gyr_tax_return)
      ], intake: intake }

      it "returns them as an array" do
        expect(intake.filing_years).to eq([2023, 2021])
      end
    end
  end

  describe "#contact_info_filtered_by_preferences" do
    let(:intake) do
      build :intake,
            sms_phone_number: "+14158161286",
            email_address: "supermane@fantastic.horse",
            email_notification_opt_in: email,
            sms_notification_opt_in: sms
    end

    context "when they want all notifications" do
      let(:email){ "yes" }
      let(:sms){ "yes" }

      it "returns email and sms_phone_number in a hash" do
        expected_result = {
          email: "supermane@fantastic.horse",
          sms_phone_number: "+14158161286",
        }
        expect(intake.contact_info_filtered_by_preferences).to eq expected_result
      end
    end

    context "when they want sms only" do
      let(:email){ "no" }
      let(:sms){ "yes" }

      it "returns sms_phone_number in a hash" do
        expected_result = {
          sms_phone_number: "+14158161286",
        }
        expect(intake.contact_info_filtered_by_preferences).to eq expected_result

      end
    end

    context "when they want email only" do
      let(:email){ "yes" }
      let(:sms){ "no" }

      it "returns email in a hash" do
        expected_result = {
          email: "supermane@fantastic.horse",
        }
        expect(intake.contact_info_filtered_by_preferences).to eq expected_result
      end
    end

    context "when they don't want any notifications" do
      let(:email){ "no" }
      let(:sms){ "no" }

      it "returns an empty hash" do
        expect(intake.contact_info_filtered_by_preferences).to eq({})
      end
    end

    context "when the intake has a different phone_number and sms_phone_number" do
      let(:intake) do
        build :intake,
              sms_phone_number: "+14159997777",
              phone_number: "+14158161286",
              email_address: "supermane@fantastic.horse",
              email_notification_opt_in: "no",
              sms_notification_opt_in: "yes"
      end

      it "uses the sms_phone_number" do
        expected_result = {
          sms_phone_number: "+14159997777",
        }

        expect(intake.contact_info_filtered_by_preferences).to eq expected_result
      end
    end
  end

  describe "#include_bank_details?" do
    let(:refund_method) {nil}
    let(:pay_from_bank) {nil}
    let(:intake) { create :intake, refund_payment_method: refund_method, balance_pay_from_bank: pay_from_bank }
    context "with an intake that wants their refund by direct deposit" do
      let(:refund_method) { "direct_deposit"}
      let(:pay_from_bank) {"no"}

      it "returns true" do
        expect(intake.include_bank_details?).to eq(true)
      end
    end

    context "with an intake that has not answered how they want their refund" do
      let(:refund_method) { "unfilled"}

      context "when they want to pay by bank account" do
        let(:pay_from_bank) {"yes"}

        it "returns false" do
          expect(intake.include_bank_details?).to eq true
        end
      end

      context "when the have not answered whether they want to pay by bank account" do
        let(:pay_from_bank) {"unfilled"}

        it "returns false" do
          expect(intake.include_bank_details?).to eq false
        end
      end

      context "when they do not want to pay by bank account" do
        let(:pay_from_bank) {"no"}

        it "returns false" do
          expect(intake.include_bank_details?).to eq false
        end
      end
    end

    context "with an intake that wants their refund by check" do
      let(:refund_method) { "check"}

      context "when they want to pay by bank account" do
        let(:pay_from_bank) {"yes"}

        it "returns false" do
          expect(intake.include_bank_details?).to eq true
        end
      end

      context "when the have not answered whether they want to pay by bank account" do
        let(:pay_from_bank) {"unfilled"}

        it "returns false" do
          expect(intake.include_bank_details?).to eq false
        end
      end

      context "when they do not want to pay by bank account" do
        let(:pay_from_bank) {"no"}

        it "returns false" do
          expect(intake.include_bank_details?).to eq false
        end
      end
    end
  end

  describe "#document_types_definitely_needed" do
    let(:intake) { create(:intake, bought_marketplace_health_insurance: "yes", had_wages: "yes") }

    it "returns list of must have documents" do
      expected_doc_types = [
        DocumentTypes::Identity,
        DocumentTypes::Selfie,
        DocumentTypes::SsnItin,
        DocumentTypes::Employment,
        DocumentTypes::Form1095A
      ]

      expect(intake.document_types_definitely_needed).to match_array expected_doc_types
    end

    context "with already uploaded documents" do
      let!(:document) { create :document, intake: intake, document_type: "Selfie" }

      it "doesn't include already uploaded documents" do
        expected_doc_types = [
          DocumentTypes::Identity,
          DocumentTypes::SsnItin,
          DocumentTypes::Employment,
          DocumentTypes::Form1095A
        ]

        expect(intake.document_types_definitely_needed).to match_array expected_doc_types
      end
    end

    context "in the skip selfies experiment" do
      before do
        Experiment.update_all(enabled: true)
        experiment = Experiment.find_by(key: ExperimentService::ID_VERIFICATION_EXPERIMENT)
        ExperimentParticipant.create!(experiment: experiment, record: intake, treatment: :no_selfie)
      end

      it "doesn't include selfies" do
        expected_doc_types = [
          DocumentTypes::Identity,
          DocumentTypes::SsnItin,
          DocumentTypes::Employment,
          DocumentTypes::Form1095A
        ]

        expect(intake.document_types_definitely_needed).to match_array expected_doc_types
      end
    end

    context "in the expanded id type experiment with other doc types uploaded" do
      let!(:primary_id_document) { create :document, intake: intake, document_type: "Passport" }
      let!(:secondary_id_document) { create :document, intake: intake, document_type: "Birth Certificate" }

      before do
        Experiment.update_all(enabled: true)
        experiment = Experiment.find_by(key: ExperimentService::ID_VERIFICATION_EXPERIMENT)
        ExperimentParticipant.create!(experiment: experiment, record: intake, treatment: :expanded_id)
      end

      it "doesn't include Identity or SsnItin" do
        expected_doc_types = [
          DocumentTypes::Selfie,
          DocumentTypes::Employment,
          DocumentTypes::Form1095A
        ]

        expect(intake.document_types_definitely_needed).to match_array expected_doc_types
      end
    end
  end

  describe "#document_types_possibly_needed" do
    let(:intake) { create(:intake, had_wages: "yes", was_full_time_student: "yes") }

    it "returns list of might have documents" do
      expect(intake.document_types_possibly_needed).to eq [DocumentTypes::StudentAccountStatement]
    end

    context "with already uploaded documents" do
      let!(:document) { create :document, intake: intake, document_type: "Student Account Statement" }

      it "doesn't include already uploaded documents" do
        expect(intake.document_types_possibly_needed).to eq []
      end
    end
  end

  describe "#update_or_create_13614c_document" do
    let(:intake) { create(:intake) }

    context "when there is not an existing 13614-C document" do
      it "creates a preliminary 13614-C PDF with a given filename" do
        expect { intake.update_or_create_13614c_document("filename.pdf") }.to change(Document, :count).by(1)

        doc = Document.last
        expect(doc.display_name).to eq("filename.pdf")
        expect(doc.document_type).to eq(DocumentTypes::Form13614C.key)
      end
    end

    context "when there is an existing 13614-C document" do
      let!(:document) { intake.update_or_create_13614c_document("filename.pdf") }

      it "updates the existing document with a regenerated form" do
        expect {
          expect {
            intake.update_or_create_13614c_document("new-filename.pdf")
          }.not_to change(Document, :count)
        }.to change{document.reload.updated_at}
        expect(document.display_name).to eq "new-filename.pdf"
      end
    end
  end

  describe "#set_navigator" do
    let(:intake) { create :intake }

    it 'sets the correct navigator boolean based on a numerical string' do
      intake.set_navigator("1")

      expect(intake.with_general_navigator?).to be_truthy
      expect(intake.with_incarcerated_navigator?).to be_falsey
      expect(intake.with_limited_english_navigator?).to be_falsey
      expect(intake.with_unhoused_navigator?).to be_falsey

      intake.set_navigator("4")

      expect(intake.with_general_navigator?).to be_truthy
      expect(intake.with_incarcerated_navigator?).to be_falsey
      expect(intake.with_limited_english_navigator?).to be_falsey
      expect(intake.with_unhoused_navigator?).to be_truthy

    end

    describe 'if the numerical value does not map to a navigator' do
      it 'does not set any navigator boolean on the intake' do
        intake.set_navigator("100")

        expect(intake.with_general_navigator?).to be_falsey
        expect(intake.with_incarcerated_navigator?).to be_falsey
        expect(intake.with_limited_english_navigator?).to be_falsey
        expect(intake.with_unhoused_navigator?).to be_falsey
      end
    end

    describe 'given a non-numerical string' do
      it 'does not set any navigator boolean on the intake' do
        intake.set_navigator("some_value")

        expect(intake.with_general_navigator?).to be_falsey
        expect(intake.with_incarcerated_navigator?).to be_falsey
        expect(intake.with_limited_english_navigator?).to be_falsey
        expect(intake.with_unhoused_navigator?).to be_falsey
      end
    end
  end

  describe "#navigator_display_names" do
    it 'returns a string a navigator types used by the intake' do
      intake_1 = create :intake, with_general_navigator: true, with_limited_english_navigator: true
      intake_2 = create :intake, with_unhoused_navigator: true, with_incarcerated_navigator: true

      expect(intake_1.navigator_display_names).to eq('General, Limited English')
      expect(intake_2.navigator_display_names).to eq('Incarcerated/reentry, Unhoused')
    end
  end

  describe "#relevant_document_types" do
    let(:intake) { create :intake, had_wages: "yes", had_interest_income: "yes", bought_marketplace_health_insurance: "no" }

    it "returns only the document type classes relevant to the client for types in the navigation flow" do
      doc_types = [
        DocumentTypes::Identity,
        DocumentTypes::Selfie,
        DocumentTypes::SsnItin,
        DocumentTypes::Employment,
        DocumentTypes::Form1099Div,
        DocumentTypes::Form1099Int,
        DocumentTypes::Other,
      ]
      expect(intake.relevant_document_types).to match_array doc_types
    end
  end

  describe "#relevant_intake_document_types" do
    let(:intake) { create :intake, had_wages: "yes", had_interest_income: "yes", bought_marketplace_health_insurance: "no" }

    it "returns only the document type classes relevant to the client for types in the navigation flow" do
      doc_types = [
        DocumentTypes::Identity,
        DocumentTypes::Selfie,
        DocumentTypes::SsnItin,
        DocumentTypes::Employment,
        DocumentTypes::Other,
      ]
      expect(intake.relevant_intake_document_types).to match_array doc_types
    end
  end

  describe "#itin_applicant?" do
    context "when there is no triage associated" do
      let(:intake) { create(:intake, need_itin_help: need_itin_help) }

      context "if need_itin_help is true" do
        let(:need_itin_help) { 'yes' }

        it "is truthy" do
          expect(intake.itin_applicant?).to be_truthy
        end
      end

      context "if need_itin_help is not true" do
        let(:need_itin_help) { 'no' }

        it "is falsey" do
          expect(intake.itin_applicant?).to be_falsey
        end
      end
    end
  end

  describe "#duplicates" do
    let(:dupe_double) { double }
    before do
      allow(DeduplicationService).to receive(:duplicates).and_return dupe_double
      allow(dupe_double).to receive(:or)
    end

    context "when hashed primary ssn is present" do
      let(:intake) { create :intake, hashed_primary_ssn: "123456789" }
      it "builds a query looking for duplicates" do
        intake.duplicates
        expect(DeduplicationService).to have_received(:duplicates).exactly(1).times.with(intake, :hashed_primary_ssn, from_scope: intake.class.accessible_intakes)
      end
    end

    context "when hashed primary ssn is not present" do
      let(:intake) { create :intake, hashed_primary_ssn: nil }
      it "responds with an empty collection" do
        expect(intake.duplicates).to be_empty
        expect(DeduplicationService).not_to have_received(:duplicates)
      end
    end

    context "when primary ssn starts with '12345'" do
      let(:intake) { create :ctc_intake, primary_ssn: '123456789' }

      before do
        allow(Rails.configuration).to receive(:allow_magic_ssn).and_return(true)
      end

      it "will not find any duplicates" do
        expect(intake.duplicates).to be_empty
        expect(DeduplicationService).not_to have_received(:duplicates)
      end
    end
  end
end
