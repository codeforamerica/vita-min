# == Schema Information
#
# Table name: intakes
#
#  id                                                   :bigint           not null, primary key
#  additional_info                                      :string
#  adopted_child                                        :integer          default(0), not null
#  advance_ctc_amount_received                          :integer
#  already_applied_for_stimulus                         :integer          default(0), not null
#  already_filed                                        :integer          default("unfilled"), not null
#  balance_pay_from_bank                                :integer          default(0), not null
#  bank_account_type                                    :integer          default("unfilled"), not null
#  bought_energy_efficient_items                        :integer
#  bought_health_insurance                              :integer          default(0), not null
#  cannot_claim_me_as_a_dependent                       :integer          default(0), not null
#  canonical_email_address                              :string
#  city                                                 :string
#  claim_owed_stimulus_money                            :integer          default("unfilled"), not null
#  claimed_by_another                                   :integer          default(0), not null
#  completed_at                                         :datetime
#  completed_yes_no_questions_at                        :datetime
#  consented_to_legal                                   :integer          default(0), not null
#  continued_at_capacity                                :boolean          default(FALSE)
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
#  demographic_questions_opt_in                         :integer          default(0), not null
#  demographic_spouse_american_indian_alaska_native     :boolean
#  demographic_spouse_asian                             :boolean
#  demographic_spouse_black_african_american            :boolean
#  demographic_spouse_ethnicity                         :integer          default(0), not null
#  demographic_spouse_native_hawaiian_pacific_islander  :boolean
#  demographic_spouse_prefer_not_to_answer_race         :boolean
#  demographic_spouse_white                             :boolean
#  demographic_veteran                                  :integer          default(0), not null
#  divorced                                             :integer          default(0), not null
#  divorced_year                                        :string
#  eip1_amount_received                                 :integer
#  eip1_and_2_amount_received_confidence                :integer
#  eip1_entry_method                                    :integer          default(0), not null
#  eip2_amount_received                                 :integer
#  eip2_entry_method                                    :integer          default(0), not null
#  eip3_amount_received                                 :integer
#  eip_only                                             :boolean
#  email_address                                        :citext
#  email_address_verified_at                            :datetime
#  email_domain                                         :string
#  email_notification_opt_in                            :integer          default("unfilled"), not null
#  encrypted_bank_account_number                        :string
#  encrypted_bank_account_number_iv                     :string
#  encrypted_bank_name                                  :string
#  encrypted_bank_name_iv                               :string
#  encrypted_bank_routing_number                        :string
#  encrypted_bank_routing_number_iv                     :string
#  encrypted_primary_ip_pin                             :string
#  encrypted_primary_ip_pin_iv                          :string
#  encrypted_primary_last_four_ssn                      :string
#  encrypted_primary_last_four_ssn_iv                   :string
#  encrypted_primary_signature_pin                      :string
#  encrypted_primary_signature_pin_iv                   :string
#  encrypted_primary_ssn                                :string
#  encrypted_primary_ssn_iv                             :string
#  encrypted_spouse_ip_pin                              :string
#  encrypted_spouse_ip_pin_iv                           :string
#  encrypted_spouse_last_four_ssn                       :string
#  encrypted_spouse_last_four_ssn_iv                    :string
#  encrypted_spouse_signature_pin                       :string
#  encrypted_spouse_signature_pin_iv                    :string
#  encrypted_spouse_ssn                                 :string
#  encrypted_spouse_ssn_iv                              :string
#  ever_married                                         :integer          default(0), not null
#  ever_owned_home                                      :integer          default(0), not null
#  feedback                                             :string
#  feeling_about_taxes                                  :integer          default(0), not null
#  filed_2020                                           :integer          default(0), not null
#  filed_prior_tax_year                                 :integer          default(0), not null
#  filing_for_stimulus                                  :integer          default(0), not null
#  filing_joint                                         :integer          default(0), not null
#  final_info                                           :string
#  had_asset_sale_income                                :integer          default(0), not null
#  had_debt_forgiven                                    :integer          default(0), not null
#  had_dependents                                       :integer          default(0), not null
#  had_disability                                       :integer          default(0), not null
#  had_disability_income                                :integer          default(0), not null
#  had_disaster_loss                                    :integer          default(0), not null
#  had_farm_income                                      :integer          default(0), not null
#  had_gambling_income                                  :integer          default(0), not null
#  had_hsa                                              :integer          default(0), not null
#  had_interest_income                                  :integer          default(0), not null
#  had_local_tax_refund                                 :integer          default(0), not null
#  had_other_income                                     :integer          default(0), not null
#  had_rental_income                                    :integer          default(0), not null
#  had_retirement_income                                :integer          default(0), not null
#  had_self_employment_income                           :integer          default(0), not null
#  had_social_security_income                           :integer          default(0), not null
#  had_social_security_or_retirement                    :integer          default(0), not null
#  had_student_in_family                                :integer          default(0), not null
#  had_tax_credit_disallowed                            :integer          default(0), not null
#  had_tips                                             :integer          default(0), not null
#  had_unemployment_income                              :integer          default(0), not null
#  had_wages                                            :integer          default(0), not null
#  has_primary_ip_pin                                   :integer          default(0), not null
#  has_spouse_ip_pin                                    :integer          default(0), not null
#  income_over_limit                                    :integer          default(0), not null
#  interview_timing_preference                          :string
#  issued_identity_pin                                  :integer          default(0), not null
#  job_count                                            :integer
#  lived_with_spouse                                    :integer          default(0), not null
#  locale                                               :string
#  made_estimated_tax_payments                          :integer          default(0), not null
#  married                                              :integer          default(0), not null
#  multiple_states                                      :integer          default(0), not null
#  navigator_has_verified_client_identity               :boolean
#  navigator_name                                       :string
#  needs_help_2016                                      :integer          default(0), not null
#  needs_help_2017                                      :integer          default(0), not null
#  needs_help_2018                                      :integer          default(0), not null
#  needs_help_2019                                      :integer          default(0), not null
#  needs_help_2020                                      :integer          default(0), not null
#  needs_help_2021                                      :integer          default(0), not null
#  needs_to_flush_searchable_data_set_at                :datetime
#  no_eligibility_checks_apply                          :integer          default(0), not null
#  no_ssn                                               :integer          default(0), not null
#  other_income_types                                   :string
#  paid_alimony                                         :integer          default(0), not null
#  paid_charitable_contributions                        :integer          default(0), not null
#  paid_dependent_care                                  :integer          default(0), not null
#  paid_local_tax                                       :integer          default(0), not null
#  paid_medical_expenses                                :integer          default(0), not null
#  paid_mortgage_interest                               :integer          default(0), not null
#  paid_retirement_contributions                        :integer          default(0), not null
#  paid_school_supplies                                 :integer          default(0), not null
#  paid_student_loan_interest                           :integer          default(0), not null
#  phone_number                                         :string
#  phone_number_can_receive_texts                       :integer          default(0), not null
#  preferred_interview_language                         :string
#  preferred_name                                       :string
#  preferred_written_language                           :string
#  primary_active_armed_forces                          :integer          default(0), not null
#  primary_birth_date                                   :date
#  primary_consented_to_service                         :integer          default("unfilled"), not null
#  primary_consented_to_service_at                      :datetime
#  primary_consented_to_service_ip                      :inet
#  primary_first_name                                   :string
#  primary_last_name                                    :string
#  primary_middle_initial                               :string
#  primary_prior_year_agi_amount                        :integer
#  primary_prior_year_signature_pin                     :string
#  primary_signature_pin_at                             :datetime
#  primary_suffix                                       :string
#  primary_tin_type                                     :integer
#  received_advance_ctc_payment                         :integer
#  received_alimony                                     :integer          default(0), not null
#  received_homebuyer_credit                            :integer          default(0), not null
#  received_irs_letter                                  :integer          default(0), not null
#  received_stimulus_payment                            :integer          default(0), not null
#  referrer                                             :string
#  refund_payment_method                                :integer          default("unfilled"), not null
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
#  spouse_can_be_claimed_as_dependent                   :integer          default(0)
#  spouse_consented_to_service                          :integer          default(0), not null
#  spouse_consented_to_service_at                       :datetime
#  spouse_consented_to_service_ip                       :inet
#  spouse_email_address                                 :citext
#  spouse_filed_prior_tax_year                          :integer          default(0), not null
#  spouse_first_name                                    :string
#  spouse_had_disability                                :integer          default(0), not null
#  spouse_issued_identity_pin                           :integer          default(0), not null
#  spouse_last_name                                     :string
#  spouse_middle_initial                                :string
#  spouse_prior_year_agi_amount                         :integer
#  spouse_prior_year_signature_pin                      :string
#  spouse_signature_pin_at                              :datetime
#  spouse_suffix                                        :string
#  spouse_tin_type                                      :integer
#  spouse_was_blind                                     :integer          default(0), not null
#  spouse_was_full_time_student                         :integer          default(0), not null
#  spouse_was_on_visa                                   :integer          default(0), not null
#  state                                                :string
#  state_of_residence                                   :string
#  street_address                                       :string
#  street_address2                                      :string
#  timezone                                             :string
#  type                                                 :string
#  use_primary_name_for_name_control                    :boolean          default(FALSE)
#  viewed_at_capacity                                   :boolean          default(FALSE)
#  vita_partner_name                                    :string
#  wants_to_itemize                                     :integer          default(0), not null
#  was_blind                                            :integer          default(0), not null
#  was_full_time_student                                :integer          default(0), not null
#  was_on_visa                                          :integer          default(0), not null
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
#  index_intakes_on_needs_to_flush_searchable_data_set_at  (needs_to_flush_searchable_data_set_at) WHERE (needs_to_flush_searchable_data_set_at IS NOT NULL)
#  index_intakes_on_phone_number                           (phone_number)
#  index_intakes_on_searchable_data                        (searchable_data) USING gin
#  index_intakes_on_sms_phone_number                       (sms_phone_number)
#  index_intakes_on_spouse_email_address                   (spouse_email_address)
#  index_intakes_on_type                                   (type)
#  index_intakes_on_vita_partner_id                        (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
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
      it "requires visitor_id" do
        expect(Intake.new).not_to be_valid
        expect(Intake.new(visitor_id: "present")).to be_valid
      end
    end
  end

  describe "keeping last 4 ssn in sync with ssn" do
    context "when creating the object" do
      let(:intake) { create :intake, primary_ssn: "12345678", spouse_ssn: "234567777" }

      it "updates last_four values when setting" do
        expect(intake.primary_last_four_ssn).to eq "5678"
        expect(intake.spouse_last_four_ssn).to eq "7777"
      end
    end

    context "primary_ssn" do
      let!(:intake) { create :intake, primary_ssn: "12345678", spouse_ssn: "2345677777" }

      context "when removing primary_ssn" do
        it "sets primary_last_four_ssn to nil" do
          expect{
            intake.update(primary_ssn: nil)
          }.to change(intake, :primary_last_four_ssn).to(nil)
        end
      end

      context "when setting primary_ssn to an empty string" do
        it "sets primary_last_four_ssn to an empty string" do
          expect{
            intake.update(primary_ssn: "")
          }.to change(intake, :primary_last_four_ssn).to("")
        end
      end

      context "when changing primary_ssn" do
        it "sets primary_last_four_ssn to a new value" do
          expect{
            intake.update(primary_ssn: "123456666")
          }.to change(intake, :primary_last_four_ssn).to("6666")
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
        it "sets spouse_last_four_ssn to a new value" do
          expect{
            intake.update(spouse_ssn: "123456666")
          }.to change(intake, :spouse_last_four_ssn).to("6666")
        end
      end
    end

  end

  describe "canonical_email_address" do
    it "is persisted when the intake is saved" do
      example_intake = Intake.create!(email_address: "a.REAL.email@example.com", visitor_id: "visitor_id")
      expect(example_intake.canonical_email_address).to eq('a.real.email@example.com')

      gmail_intake = Intake.create!(email_address: "a.REAL.email@gmail.com", visitor_id: "visitor_id")
      expect(gmail_intake.canonical_email_address).to eq('arealemail@gmail.com')
    end
  end

  describe "email_address" do
    it "searches case-insensitively" do
      intake = Intake.create!(email_address: "eXample@EXAMPLE.COM", visitor_id: "visitor_id")
      expect(Intake.where(email_address: "example@example.com")).to include(intake)
    end
  end

  describe "email_domain" do
    it "is persisted when the intake is saved" do
      example_intake = Intake.create!(email_address: "a.REAL.email@example.com", visitor_id: "visitor_id")
      expect(example_intake.email_domain).to eq('example.com')

      gmail_intake = Intake.create!(email_address: "a.REAL.email@gmail.com", visitor_id: "visitor_id")
      expect(gmail_intake.email_domain).to eq('gmail.com')
    end
  end

  describe "spouse_email_address" do
    it "searches case-insensitively" do
      intake = Intake.create!(spouse_email_address: "eXample@EXAMPLE.COM", visitor_id: "visitor_id")
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
        described_class.refresh_search_index
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
      let(:intake) { create :intake, had_student_in_family: "yes" }

      it "returns true" do
        expect(intake.any_students?).to eq true
      end
    end
  end

  describe "#student_names" do
    context "when everyone is a student" do
      let(:intake) do
        create :intake,
          was_full_time_student: "yes",
          spouse_was_full_time_student: "yes",
          primary_first_name: "Henrietta",
          primary_last_name: "Huckleberry",
          spouse_first_name: "Helga",
          spouse_last_name: "Huckleberry"
      end
      before do
        create :dependent, intake: intake, first_name: "Harriet", last_name: "Huckleberry", was_student: "yes"
        create :dependent, intake: intake, first_name: "Henry", last_name: "Huckleberry", was_student: "yes"
      end

      it "returns all the names" do
        expected_results = [
          "Henrietta Huckleberry",
          "Helga Huckleberry",
          "Harriet Huckleberry",
          "Henry Huckleberry",
        ]
        expect(intake.student_names).to eq(expected_results)
      end
    end

    context "when only one dependent is a student" do
      let(:intake) do
        create :intake,
          was_full_time_student: "no",
          spouse_was_full_time_student: "unfilled",
          primary_first_name: "Henrietta",
          primary_last_name: "Huckleberry",
          spouse_first_name: "Helga",
          spouse_last_name: "Huckleberry"
      end

      before do
        create :dependent, intake: intake, first_name: "Harriet", last_name: "Huckleberry", was_student: "yes"
        create :dependent, intake: intake, first_name: "Henry", last_name: "Huckleberry", was_student: "no"
      end

      it "returns only one name" do
        expected_results = [
          "Harriet Huckleberry",
        ]
        expect(intake.student_names).to eq(expected_results)
      end
    end

    context "when no one is a student" do
      let(:intake) do
        create :intake,
          was_full_time_student: "no",
          spouse_was_full_time_student: "no",
          primary_first_name: "Henrietta",
          primary_last_name: "Huckleberry",
          spouse_first_name: "Helga",
          spouse_last_name: "Huckleberry"
      end

      before do
        create :dependent, intake: intake, first_name: "Harriet", last_name: "Huckleberry", was_student: "no"
        create :dependent, intake: intake, first_name: "Henry", last_name: "Huckleberry", was_student: "no"
      end

      it "returns an empty array" do
        expect(intake.student_names).to eq([])
      end
    end

    context "when there is no spouse verified but the spouse was a student" do
      let(:intake) do
        create :intake,
          was_full_time_student: "yes",
          spouse_was_full_time_student: "yes",
          primary_first_name: "Henrietta",
          primary_last_name: "Huckleberry"
      end

      it "shows a placeholder for the spouse name" do
        expect(intake.student_names).to eq(["Henrietta Huckleberry", "Your spouse"])
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
    let(:intake) { create :intake }
    let!(:client) { create :client, tax_returns: [], intake: intake }
    let(:tax_returns) { [] }

    context "with unfilled filing years" do
      it "returns empty array" do
        expect(intake.filing_years).to eq([])
      end
    end

    context "with a couple filing years selected" do
      let!(:client) { create :client, tax_returns: [
        create(:tax_return, year: 2019),
        create(:tax_return, year: 2021)
      ], intake: intake }

      it "returns them as an array" do
        expect(intake.filing_years).to eq([2021, 2019])
      end
    end
  end

  describe "#most_recent_filing_year" do
    let(:intake) { create :intake }
    let!(:client) { create :client, tax_returns: [], intake: intake }

    context "with unfilled filing years" do
      it "returns current tax year" do
        expect(intake.most_recent_filing_year).to eq TaxReturn.current_tax_year
      end
    end

    context "with multiple years" do
      let!(:client) { create :client, tax_returns: [
          create(:tax_return, year: 2019),
          create(:tax_return, year: 2018)
      ], intake: intake }

      it "returns most recent" do
        expect(intake.most_recent_filing_year).to eq(2019)
      end
    end
  end

  describe "#year_before_most_recent_filing_year" do
    let(:intake) { create :intake }
    let!(:client) { create :client, tax_returns: [], intake: intake }

    context "with unfilled filing years" do
      it "returns 2019" do
        expect(intake.year_before_most_recent_filing_year).to eq 2020
      end
    end

    context "when a year is selected" do
      let!(:client) { create :client, tax_returns: [
          create(:tax_return, year: 2019),
          create(:tax_return, year: 2018)
      ], intake: intake }

      it "returns the year before most recent filing year as a string" do
        expect(intake.year_before_most_recent_filing_year).to eq 2018
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
    let(:intake) { create(:intake, bought_health_insurance: "yes", had_wages: "yes") }

    it "returns list of must have documents" do
      expected_doc_types = [
        DocumentTypes::Identity,
        DocumentTypes::Selfie,
        DocumentTypes::SsnItin,
        DocumentTypes::Employment,
        DocumentTypes::Form1095A
      ]

      expect(intake.document_types_definitely_needed).to eq expected_doc_types
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

        expect(intake.document_types_definitely_needed).to eq expected_doc_types
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
    let(:intake) { create :intake, had_wages: "yes", had_interest_income: "yes", bought_health_insurance: "no" }

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
      expect(intake.relevant_document_types).to eq doc_types
    end
  end

  describe "#relevant_intake_document_types" do
    let(:intake) { create :intake, had_wages: "yes", had_interest_income: "yes", bought_health_insurance: "no" }

    it "returns only the document type classes relevant to the client for types in the navigation flow" do
      doc_types = [
        DocumentTypes::Identity,
        DocumentTypes::Selfie,
        DocumentTypes::SsnItin,
        DocumentTypes::Employment,
        DocumentTypes::Other,
      ]
      expect(intake.relevant_intake_document_types).to eq doc_types
    end
  end
end
