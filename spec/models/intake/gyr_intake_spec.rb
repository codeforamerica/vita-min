# == Schema Information
#
# Table name: intakes
#
#  id                                                   :bigint           not null, primary key
#  additional_info                                      :string
#  adopted_child                                        :integer          default("unfilled"), not null
#  advance_ctc_amount_received                          :integer
#  advance_ctc_entry_method                             :integer          default(0), not null
#  already_applied_for_stimulus                         :integer          default("unfilled"), not null
#  already_filed                                        :integer          default("unfilled"), not null
#  balance_pay_from_bank                                :integer          default("unfilled"), not null
#  bank_account_number                                  :text
#  bank_account_type                                    :integer          default("unfilled"), not null
#  bank_name                                            :string
#  bank_routing_number                                  :string
#  bought_employer_health_insurance                     :integer          default("unfilled"), not null
#  bought_energy_efficient_items                        :integer
#  bought_marketplace_health_insurance                  :integer          default("unfilled"), not null
#  cannot_claim_me_as_a_dependent                       :integer          default(0), not null
#  canonical_email_address                              :string
#  city                                                 :string
#  claim_eitc                                           :integer          default(0), not null
#  claim_owed_stimulus_money                            :integer          default("unfilled"), not null
#  claimed_by_another                                   :integer          default("unfilled"), not null
#  completed_at                                         :datetime
#  completed_yes_no_questions_at                        :datetime
#  consented_to_legal                                   :integer          default(0), not null
#  continued_at_capacity                                :boolean          default(FALSE)
#  contributed_to_401k                                  :integer          default("unfilled"), not null
#  contributed_to_ira                                   :integer          default("unfilled"), not null
#  contributed_to_other_retirement_account              :integer          default("unfilled"), not null
#  contributed_to_roth_ira                              :integer          default("unfilled"), not null
#  current_step                                         :string
#  demographic_disability                               :integer          default("unfilled"), not null
#  demographic_english_conversation                     :integer          default("unfilled"), not null
#  demographic_english_reading                          :integer          default("unfilled"), not null
#  demographic_primary_american_indian_alaska_native    :boolean
#  demographic_primary_asian                            :boolean
#  demographic_primary_black_african_american           :boolean
#  demographic_primary_ethnicity                        :integer          default("unfilled"), not null
#  demographic_primary_native_hawaiian_pacific_islander :boolean
#  demographic_primary_prefer_not_to_answer_race        :boolean
#  demographic_primary_white                            :boolean
#  demographic_questions_hub_edit                       :boolean          default(FALSE)
#  demographic_questions_opt_in                         :integer          default("unfilled"), not null
#  demographic_spouse_american_indian_alaska_native     :boolean
#  demographic_spouse_asian                             :boolean
#  demographic_spouse_black_african_american            :boolean
#  demographic_spouse_ethnicity                         :integer          default("unfilled"), not null
#  demographic_spouse_native_hawaiian_pacific_islander  :boolean
#  demographic_spouse_prefer_not_to_answer_race         :boolean
#  demographic_spouse_white                             :boolean
#  demographic_veteran                                  :integer          default("unfilled"), not null
#  disallowed_ctc                                       :boolean
#  divorced                                             :integer          default("unfilled"), not null
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
#  ever_married                                         :integer          default("unfilled"), not null
#  ever_owned_home                                      :integer          default("unfilled"), not null
#  exceeded_investment_income_limit                     :integer          default(0)
#  feedback                                             :string
#  feeling_about_taxes                                  :integer          default("unfilled"), not null
#  filed_2020                                           :integer          default(0), not null
#  filed_prior_tax_year                                 :integer          default(0), not null
#  filing_for_stimulus                                  :integer          default("unfilled"), not null
#  filing_joint                                         :integer          default("unfilled"), not null
#  final_info                                           :string
#  former_foster_youth                                  :integer          default(0), not null
#  full_time_student_less_than_five_months              :integer          default(0), not null
#  got_married_during_tax_year                          :integer          default("unfilled"), not null
#  had_asset_sale_income                                :integer          default("unfilled"), not null
#  had_capital_loss_carryover                           :integer          default("unfilled"), not null
#  had_cash_check_digital_assets                        :integer          default("unfilled"), not null
#  had_debt_forgiven                                    :integer          default("unfilled"), not null
#  had_dependents                                       :integer          default("unfilled"), not null
#  had_disability                                       :integer          default("unfilled"), not null
#  had_disability_income                                :integer          default("unfilled"), not null
#  had_disaster_loss                                    :integer          default("unfilled"), not null
#  had_disaster_loss_where                              :string
#  had_disqualifying_non_w2_income                      :integer
#  had_farm_income                                      :integer          default("unfilled"), not null
#  had_gambling_income                                  :integer          default("unfilled"), not null
#  had_hsa                                              :integer          default("unfilled"), not null
#  had_interest_income                                  :integer          default("unfilled"), not null
#  had_local_tax_refund                                 :integer          default("unfilled"), not null
#  had_medicaid_medicare                                :integer          default("unfilled"), not null
#  had_other_income                                     :integer          default("unfilled"), not null
#  had_rental_income                                    :integer          default("unfilled"), not null
#  had_retirement_income                                :integer          default("unfilled"), not null
#  had_scholarships                                     :integer          default("unfilled"), not null
#  had_self_employment_income                           :integer          default("unfilled"), not null
#  had_social_security_income                           :integer          default("unfilled"), not null
#  had_social_security_or_retirement                    :integer          default("unfilled"), not null
#  had_tax_credit_disallowed                            :integer          default("unfilled"), not null
#  had_tips                                             :integer          default("unfilled"), not null
#  had_unemployment_income                              :integer          default("unfilled"), not null
#  had_w2s                                              :integer          default(0), not null
#  had_wages                                            :integer          default("unfilled"), not null
#  has_crypto_income                                    :boolean          default(FALSE)
#  has_primary_ip_pin                                   :integer          default(0), not null
#  has_spouse_ip_pin                                    :integer          default(0), not null
#  has_ssn_of_alimony_recipient                         :integer          default("unfilled"), not null
#  hashed_primary_ssn                                   :string
#  hashed_spouse_ssn                                    :string
#  home_location                                        :integer
#  homeless_youth                                       :integer          default(0), not null
#  income_over_limit                                    :integer          default("unfilled"), not null
#  interview_timing_preference                          :string
#  irs_language_preference                              :integer
#  issued_identity_pin                                  :integer          default("unfilled"), not null
#  job_count                                            :integer
#  lived_with_spouse                                    :integer          default("unfilled"), not null
#  locale                                               :string
#  made_estimated_tax_payments                          :integer          default("unfilled"), not null
#  made_estimated_tax_payments_amount                   :decimal(12, 2)
#  married                                              :integer          default("unfilled"), not null
#  multiple_states                                      :integer          default("unfilled"), not null
#  navigator_has_verified_client_identity               :boolean
#  navigator_name                                       :string
#  need_itin_help                                       :integer          default("unfilled"), not null
#  needs_help_2016                                      :integer          default("unfilled"), not null
#  needs_help_2018                                      :integer          default("unfilled"), not null
#  needs_help_2019                                      :integer          default("unfilled"), not null
#  needs_help_2020                                      :integer          default("unfilled"), not null
#  needs_help_2021                                      :integer          default("unfilled"), not null
#  needs_help_2022                                      :integer          default("unfilled"), not null
#  needs_help_current_year                              :integer          default("unfilled"), not null
#  needs_help_previous_year_1                           :integer          default("unfilled"), not null
#  needs_help_previous_year_2                           :integer          default("unfilled"), not null
#  needs_help_previous_year_3                           :integer          default("unfilled"), not null
#  needs_to_flush_searchable_data_set_at                :datetime
#  no_eligibility_checks_apply                          :integer          default("unfilled"), not null
#  no_ssn                                               :integer          default("unfilled"), not null
#  not_full_time_student                                :integer          default(0), not null
#  other_income_types                                   :string
#  paid_alimony                                         :integer          default("unfilled"), not null
#  paid_charitable_contributions                        :integer          default("unfilled"), not null
#  paid_dependent_care                                  :integer          default("unfilled"), not null
#  paid_local_tax                                       :integer          default("unfilled"), not null
#  paid_medical_expenses                                :integer          default("unfilled"), not null
#  paid_mortgage_interest                               :integer          default("unfilled"), not null
#  paid_post_secondary_educational_expenses             :integer          default("unfilled"), not null
#  paid_retirement_contributions                        :integer          default("unfilled"), not null
#  paid_school_supplies                                 :integer          default("unfilled"), not null
#  paid_self_employment_expenses                        :integer          default("unfilled"), not null
#  paid_student_loan_interest                           :integer          default("unfilled"), not null
#  phone_carrier                                        :string
#  phone_number                                         :string
#  phone_number_can_receive_texts                       :integer          default("unfilled"), not null
#  phone_number_type                                    :string
#  preferred_interview_language                         :string
#  preferred_name                                       :string
#  preferred_written_language                           :string
#  presidential_campaign_fund_donation                  :integer          default("unfilled"), not null
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
#  primary_us_citizen                                   :integer          default("unfilled"), not null
#  product_year                                         :integer          not null
#  receive_written_communication                        :integer          default("unfilled"), not null
#  received_advance_ctc_payment                         :integer
#  received_alimony                                     :integer          default("unfilled"), not null
#  received_homebuyer_credit                            :integer          default("unfilled"), not null
#  received_irs_letter                                  :integer          default("unfilled"), not null
#  received_stimulus_payment                            :integer          default("unfilled"), not null
#  referrer                                             :string
#  refund_payment_method                                :integer          default("unfilled"), not null
#  register_to_vote                                     :integer          default("unfilled"), not null
#  reported_asset_sale_loss                             :integer          default("unfilled"), not null
#  reported_self_employment_loss                        :integer          default("unfilled"), not null
#  requested_docs_token                                 :string
#  requested_docs_token_created_at                      :datetime
#  routed_at                                            :datetime
#  routing_criteria                                     :string
#  routing_value                                        :string
#  satisfaction_face                                    :integer          default("unfilled"), not null
#  savings_purchase_bond                                :integer          default("unfilled"), not null
#  savings_split_refund                                 :integer          default("unfilled"), not null
#  searchable_data                                      :tsvector
#  separated                                            :integer          default("unfilled"), not null
#  separated_year                                       :string
#  signature_method                                     :integer          default("online"), not null
#  sms_notification_opt_in                              :integer          default("unfilled"), not null
#  sms_phone_number                                     :string
#  sms_phone_number_verified_at                         :datetime
#  sold_a_home                                          :integer          default("unfilled"), not null
#  sold_assets                                          :integer          default("unfilled"), not null
#  source                                               :string
#  spouse_active_armed_forces                           :integer          default(0)
#  spouse_auth_token                                    :string
#  spouse_birth_date                                    :date
#  spouse_consented_to_service                          :integer          default("unfilled"), not null
#  spouse_consented_to_service_at                       :datetime
#  spouse_consented_to_service_ip                       :inet
#  spouse_email_address                                 :citext
#  spouse_filed_prior_tax_year                          :integer          default(0), not null
#  spouse_first_name                                    :string
#  spouse_had_disability                                :integer          default("unfilled"), not null
#  spouse_ip_pin                                        :text
#  spouse_issued_identity_pin                           :integer          default("unfilled"), not null
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
#  spouse_us_citizen                                    :integer          default("unfilled"), not null
#  spouse_was_blind                                     :integer          default("unfilled"), not null
#  spouse_was_full_time_student                         :integer          default("unfilled"), not null
#  state                                                :string
#  state_of_residence                                   :string
#  street_address                                       :string
#  street_address2                                      :string
#  tax_credit_disallowed_year                           :integer
#  timezone                                             :string
#  triage_filing_frequency                              :integer          default("unfilled"), not null
#  triage_filing_status                                 :integer          default("unfilled"), not null
#  triage_income_level                                  :integer          default("unfilled"), not null
#  triage_vita_income_ineligible                        :integer          default("unfilled"), not null
#  type                                                 :string
#  urbanization                                         :string
#  use_primary_name_for_name_control                    :boolean          default(FALSE)
#  used_itin_certifying_acceptance_agent                :boolean          default(FALSE), not null
#  usps_address_late_verification_attempts              :integer          default(0)
#  usps_address_verified_at                             :datetime
#  viewed_at_capacity                                   :boolean          default(FALSE)
#  wants_to_itemize                                     :integer          default("unfilled"), not null
#  was_blind                                            :integer          default("unfilled"), not null
#  was_full_time_student                                :integer          default("unfilled"), not null
#  widowed                                              :integer          default("unfilled"), not null
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

describe Intake::GyrIntake do
  describe "touch behavior" do
    context "when a property is changed on the intake" do
      it "denormalizes required document info onto the client" do
        intake = create :intake

        client = intake.client.reload
        expect(client.filterable_percentage_of_required_documents_uploaded).to eq(0)
        expect(client.filterable_number_of_required_documents_uploaded).to eq(0)
        expect(client.filterable_number_of_required_documents).to eq(3)
      end
    end
  end

  describe ".accessible_intakes" do
    context "a consented intake" do
      let!(:intake) { create :intake, primary_consented_to_service: "yes" }
      it "appears as an accessible intake" do
        expect(described_class.accessible_intakes).to include intake
      end
    end

    context "not consented intakes" do
      let!(:intake) { create :intake, primary_consented_to_service: "unfilled" }
      it "are not present in the accessible intakes" do
        expect(described_class.accessible_intakes).not_to include intake
      end
    end
  end

  describe "#duplicates" do
    context "when an itin applicant" do
      let(:dupe_double) { double }
      before do
        allow(DeduplicationService).to receive(:duplicates).and_return dupe_double
        allow(dupe_double).to receive(:or)
      end
      context "when only email is present" do
        let(:intake) { create :intake, primary_birth_date: Date.tomorrow, email_address: "mango@example.com", sms_phone_number: nil, need_itin_help: "yes" }
        it "responds with duplicates from birth date and email" do
          intake.duplicates
          expect(DeduplicationService).to have_received(:duplicates).exactly(1).times.with(intake, :email_address, :primary_birth_date, from_scope: described_class.accessible_intakes)
        end
      end

      context "when only sms is present" do
        let(:intake) { create :intake, primary_birth_date: Date.tomorrow, email_address: nil, sms_phone_number: "+18324658840", need_itin_help: "yes" }
        it "responds with duplicates from sms" do
          intake.duplicates
          expect(DeduplicationService).to have_received(:duplicates).exactly(1).times.with(intake, :sms_phone_number, :primary_birth_date, from_scope: described_class.accessible_intakes)
        end
      end

      context "when both email and sms are present" do
        let(:intake) { create :intake, primary_birth_date: Date.tomorrow, email_address: "mango@example.com", sms_phone_number: "+18324658840", need_itin_help: "yes" }
        it "responds with duplicates from both email and sms" do
          intake.duplicates
          expect(DeduplicationService).to have_received(:duplicates).exactly(2).times
        end
      end

      context "when neither phone number nor email are present" do
        let(:intake) { create :intake, primary_birth_date: Date.tomorrow, email_address: nil, sms_phone_number: nil, need_itin_help: "yes" }
        it "responds with an empty ActiveRecord relation" do
          expect(intake.duplicates).to eq described_class.none
        end
      end
    end

    context "when not an itin applicant" do
      context "when hashed_primary_ssn is nil" do
        let(:intake) { create :intake, primary_ssn: nil }

        it "returns an empty active record collection" do
          expect(intake.duplicates).to eq described_class.none
        end
      end

      context "when there is another accessible intake with the same ssn" do
        let!(:dupe) {
          (create :gyr_tax_return, client: (create :client, intake: build(:intake, primary_consented_to_service: 'yes', primary_ssn: "123456789")), service_type: "drop_off").intake
        }
        let(:intake) { create :intake, primary_ssn: "123456789" }
        it "returns that as a duplicate" do
          expect(intake.duplicates).to include dupe
        end
      end
    end

  end
  describe "after_save when the intake is completed" do
    it_behaves_like "an incoming interaction" do
      let(:subject) { create :intake }
      before { subject.completed_at = Time.now }
    end
  end

  describe "after_save when the intake has already been completed" do
    it_behaves_like "an internal interaction" do
      let(:subject) { create :intake, completed_at: Time.now }
    end
    #failing b/c updated_at hasn't changed

    # it "updates the associated client" do
    #   expect { subject.save }
    #     .to change(subject.client, :last_internal_or_outgoing_interaction_at)
    #     .and not_change(subject.client, :last_incoming_interaction_at)
    #     .and change(subject.client, :updated_at)
    # end
  end

  describe "#probable_previous_year_intake" do

    context "when there is a matching intake with same first, last, birthday, and last 4 ssn" do
      let!(:archived_intake) { create :archived_2021_gyr_intake, primary_birth_date: Date.new(1929, 3, 22), primary_first_name: "Seth", primary_last_name: "Strawberry", primary_last_four_ssn: 1234 }
      let(:intake) { create :intake, primary_birth_date: Date.new(1929, 3, 22), primary_first_name: "Seth", primary_last_name: "Strawberry", primary_ssn: "12341234" }

      it "returns the Archived::Intake2021 object" do
        expect(intake.probable_previous_year_intake).to eq archived_intake
      end
    end

    context "when there is not a matching intake" do
      let(:intake) { create :intake, primary_birth_date: Date.new(1929, 3, 21), primary_first_name: "Seth", primary_last_name: "Strawberry", primary_ssn: "12341234" }
      let(:intake) { create :intake, primary_birth_date: Date.new(1929, 3, 22), primary_first_name: "Seth", primary_last_name: "Strawberry", primary_ssn: "12341234" }

      it "returns nil" do
        expect(intake.probable_previous_year_intake).to eq nil
      end
    end
  end
  describe "#most_recent_filing_year" do
    let(:intake) { build :intake }
    let!(:client) { create :client, tax_returns: [], intake: intake }

    context "with unfilled filing years" do
      it "returns current tax year" do
        expect(intake.most_recent_filing_year).to eq MultiTenantService.new(:gyr).current_tax_year
      end
    end

    context "with multiple years" do
      let!(:client) { create :client, tax_returns: [
        build(:tax_return, year: 2019),
        build(:tax_return, year: 2018)
      ], intake: intake }

      it "returns most recent" do
        expect(intake.most_recent_filing_year).to eq(2019)
      end
    end
  end

  describe "#most_recent_needs_help_or_filing_year" do
    let(:intake) { build(:intake) }

    context "when there are no tax returns" do
      context "when client has said which years they need help" do
        before do
          intake.update(needs_help_previous_year_3: "yes", needs_help_previous_year_2: "yes")
        end

        it "gives the highest needs_help year number" do
          expect(intake.most_recent_needs_help_or_filing_year).to eq MultiTenantService.new(:gyr).current_tax_year - 2
        end
      end

      context "when the client has not said they need help any particular years" do
        it "uses the current tax year" do
          expect(intake.most_recent_needs_help_or_filing_year).to eq MultiTenantService.new(:gyr).current_tax_year
        end
      end
    end
  end

  describe "#year_before_most_recent_filing_year" do
    let(:intake) { build :intake }
    let!(:client) { create :client, tax_returns: [], intake: intake }

    context "with unfilled filing years" do
      it "returns prior tax year" do
        expect(intake.year_before_most_recent_filing_year).to eq 2022
      end
    end

    context "when a year is selected" do
      let!(:client) { create :client, tax_returns: [
        build(:tax_return, year: 2019),
        build(:tax_return, year: 2018)
      ], intake: intake }

      it "returns the year before most recent filing year" do
        expect(intake.year_before_most_recent_filing_year).to eq 2018
      end
    end
  end

  describe "#matching_previous_year_intakes" do
    let(:ssn) { "123456789" }
    let(:birth_date) { Date.parse("1989-08-22") }
    let(:intake) { create :intake, primary_ssn: :ssn, primary_birth_date: birth_date }
    let!(:intake_2022_all_matching) { create :intake, product_year: "2022", primary_ssn: :ssn, primary_birth_date: birth_date, client: create(:client, tax_returns: [build(:gyr_tax_return, :intake_ready_for_call)]) }
    let!(:intake_2022_non_matching_dob) { create :intake, product_year: "2022", primary_ssn: :ssn, primary_birth_date: Date.parse("1996-10-12"), client: create(:client, tax_returns: [build(:gyr_tax_return, :review_signature_requested)]) }
    let!(:intake_2022_non_matching_ssn) { create :intake, product_year: "2022", primary_ssn: "123456999", primary_birth_date: birth_date, client: create(:client, tax_returns: [build(:gyr_tax_return, :review_reviewing)]) }

    it "returns intakes from previous product years with matching SSN, DOB and with a qualifying tax return current state" do
      expect(intake.matching_previous_year_intakes).to match_array [intake_2022_all_matching]
    end
  end

  describe ".previous_year_completed_intakes" do
    let!(:intake_current_year) { create(:client, intake: build(:intake, product_year: Rails.configuration.product_year)).intake }
    let!(:intake_2022_bad_tax_return_state) { create(:client, intake: build(:intake, product_year: "2022"), tax_returns: [build(:gyr_tax_return, :file_mailed)]).intake }
    let!(:intake_2022) { create(:client, intake: build(:intake, product_year: "2022"), tax_returns: [build(:gyr_tax_return, :intake_ready_for_call)]).intake }

    it "returns intakes from the previous product years with INCLUDED_IN_PREVIOUS_YEAR_COMPLETED_INTAKES tax return states" do
      expect(described_class.previous_year_completed_intakes).to match_array  [intake_2022]
    end
  end

  describe "#triaged_intake?" do
    context "when triage values are unfilled" do
      let(:intake) { create :intake, triage_income_level: "unfilled", triage_filing_status: "unfilled", triage_filing_frequency: "unfilled", triage_vita_income_ineligible: "unfilled" }

      it "returns false" do
        expect(intake.triaged_intake?).to eq false
      end
    end

    context "when triage values are not unfilled" do
      let(:intake) { create :intake, triage_income_level: "zero", triage_filing_status: "single", triage_filing_frequency: "every_year", triage_vita_income_ineligible: "yes" }

      it "returns true" do
        expect(intake.triaged_intake?).to eq true
      end
    end
  end
end
