# == Schema Information
#
# Table name: intakes
#
#  id                                                   :bigint           not null, primary key
#  additional_info                                      :string
#  adopted_child                                        :integer          default(0), not null
#  already_applied_for_stimulus                         :integer          default(0), not null
#  already_filed                                        :integer          default(0), not null
#  balance_pay_from_bank                                :integer          default(0), not null
#  bank_account_type                                    :integer          default("unfilled"), not null
#  bought_energy_efficient_items                        :integer
#  bought_health_insurance                              :integer          default(0), not null
#  city                                                 :string
#  claimed_by_another                                   :integer          default(0), not null
#  completed_at                                         :datetime
#  completed_yes_no_questions_at                        :datetime
#  continued_at_capacity                                :boolean          default(FALSE)
#  ctc_refund_delivery_method                           :integer
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
#  eip_only                                             :boolean
#  email_address                                        :citext
#  email_notification_opt_in                            :integer          default("unfilled"), not null
#  encrypted_bank_account_number                        :string
#  encrypted_bank_account_number_iv                     :string
#  encrypted_bank_name                                  :string
#  encrypted_bank_name_iv                               :string
#  encrypted_bank_routing_number                        :string
#  encrypted_bank_routing_number_iv                     :string
#  encrypted_primary_last_four_ssn                      :string
#  encrypted_primary_last_four_ssn_iv                   :string
#  encrypted_primary_ssn                                :string
#  encrypted_primary_ssn_iv                             :string
#  encrypted_spouse_last_four_ssn                       :string
#  encrypted_spouse_last_four_ssn_iv                    :string
#  encrypted_spouse_ssn                                 :string
#  encrypted_spouse_ssn_iv                              :string
#  ever_married                                         :integer          default(0), not null
#  ever_owned_home                                      :integer          default(0), not null
#  feedback                                             :string
#  feeling_about_taxes                                  :integer          default(0), not null
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
#  primary_birth_date                                   :date
#  primary_consented_to_service                         :integer          default("unfilled"), not null
#  primary_consented_to_service_at                      :datetime
#  primary_consented_to_service_ip                      :inet
#  primary_first_name                                   :string
#  primary_ip_pin                                       :integer
#  primary_last_name                                    :string
#  received_alimony                                     :integer          default(0), not null
#  received_homebuyer_credit                            :integer          default(0), not null
#  received_irs_letter                                  :integer          default(0), not null
#  received_stimulus_payment                            :integer          default(0), not null
#  recovery_rebate_credit_amount_1                      :integer
#  recovery_rebate_credit_amount_2                      :integer
#  recovery_rebate_credit_amount_confidence             :integer
#  referrer                                             :string
#  refund_payment_method                                :integer          default(0), not null
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
#  sold_a_home                                          :integer          default(0), not null
#  sold_assets                                          :integer          default(0), not null
#  source                                               :string
#  spouse_auth_token                                    :string
#  spouse_birth_date                                    :date
#  spouse_consented_to_service                          :integer          default(0), not null
#  spouse_consented_to_service_at                       :datetime
#  spouse_consented_to_service_ip                       :inet
#  spouse_email_address                                 :citext
#  spouse_first_name                                    :string
#  spouse_had_disability                                :integer          default(0), not null
#  spouse_ip_pin                                        :integer
#  spouse_issued_identity_pin                           :integer          default(0), not null
#  spouse_last_name                                     :string
#  spouse_was_blind                                     :integer          default(0), not null
#  spouse_was_full_time_student                         :integer          default(0), not null
#  spouse_was_on_visa                                   :integer          default(0), not null
#  state                                                :string
#  state_of_residence                                   :string
#  street_address                                       :string
#  timezone                                             :string
#  triage_source_type                                   :string
#  type                                                 :string
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
#  created_at                                           :datetime
#  updated_at                                           :datetime
#  client_id                                            :bigint
#  triage_source_id                                     :bigint
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
#  index_intakes_on_client_id                                (client_id)
#  index_intakes_on_email_address                            (email_address)
#  index_intakes_on_needs_to_flush_searchable_data_set_at    (needs_to_flush_searchable_data_set_at) WHERE (needs_to_flush_searchable_data_set_at IS NOT NULL)
#  index_intakes_on_phone_number                             (phone_number)
#  index_intakes_on_searchable_data                          (searchable_data) USING gin
#  index_intakes_on_sms_phone_number                         (sms_phone_number)
#  index_intakes_on_triage_source_type_and_triage_source_id  (triage_source_type,triage_source_id)
#  index_intakes_on_vita_partner_id                          (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#

require "rails_helper"

describe Intake::CtcIntake do
  describe "#any_ip_pins?" do
    context "when any member of household has an IP PIN" do
      let(:intake) { create :ctc_intake, dependents: [ create(:dependent, ssn: '111-22-3333', ip_pin: 123456) ] }

      it "returns true" do
        expect(intake.any_ip_pins?).to eq true
      end
    end

    context "when no member of household has an IP PIN" do
      let(:intake) { create :ctc_intake }

      it "returns false" do
        expect(intake.any_ip_pins?).to eq false
      end
    end
  end

  describe "#rrc_eligible_filer_count" do
    context "when filing status is single" do
      let(:intake) { create :ctc_intake, primary_tin_type: :itin, client: client }
      let(:client) { create :client, tax_returns: [create(:tax_return, year: 2020, filing_status: :single)] }
      context "when the primary is using an ITIN" do
        it "filer_count is 0" do
          expect(intake.rrc_eligible_filer_count).to eq 0
        end
      end

      context "when the primary is using an SSN" do
        let(:intake) { create :ctc_intake, primary_tin_type: :ssn, client: client }
        let(:client) { create :client, tax_returns: [create(:tax_return, year: 2020, filing_status: :single)] }
        it "filer count is 1" do
          expect(intake.rrc_eligible_filer_count).to eq 1
        end
      end
    end

    context "when filing with a spouse" do
      let(:client) { create :client, tax_returns: [create(:tax_return, year: 2020, filing_status: :married_filing_jointly)] }
      let(:spouse_military) { "no" }
      let(:primary_military) { "no" }
      let(:primary_tin_type) { "itin" }
      let(:spouse_tin_type) { "itin"}
      let(:intake) do
        create :ctc_intake,
               client: client,
               spouse_active_armed_forces: spouse_military,
               primary_active_armed_forces: primary_military,
               spouse_tin_type: spouse_tin_type,
               primary_tin_type: primary_tin_type
      end

      context "when a spouse is part of the armed forces" do
        let(:spouse_military) { "yes" }
        it "has a filer count of 2" do
          expect(intake.rrc_eligible_filer_count).to eq 2
        end
      end

      context "when primary is part of the armed forces" do
        let(:primary_military) { "yes" }

        it "has a filer count of 2" do
          expect(intake.rrc_eligible_filer_count).to eq 2
        end
      end

      context "when primary is using an ssn and spouse is using ITIN" do
        let(:primary_tin_type) { "ssn" }

        it "has a filer count of one" do
          expect(intake.rrc_eligible_filer_count).to eq 1
        end
      end

      context "when primary is using an ITIN and spouse is using SSN" do
        let(:spouse_tin_type) { "ssn" }

        it "has a filer count of one" do
          expect(intake.rrc_eligible_filer_count).to eq 1
        end
      end

      context "when both are using ITIN" do
        it "has a filer count of 0" do
          expect(intake.rrc_eligible_filer_count).to eq 0
        end
      end
    end
  end

end
