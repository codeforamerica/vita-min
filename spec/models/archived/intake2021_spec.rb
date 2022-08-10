# == Schema Information
#
# Table name: archived_intakes_2021
#
#  id                                                   :bigint           not null, primary key
#  additional_info                                      :string
#  adopted_child                                        :integer          default(0), not null
#  already_applied_for_stimulus                         :integer          default(0), not null
#  already_filed                                        :integer          default("unfilled"), not null
#  balance_pay_from_bank                                :integer          default(0), not null
#  bank_account_number                                  :text
#  bank_account_type                                    :integer          default("unfilled"), not null
#  bank_name                                            :string
#  bank_routing_number                                  :string
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
#  primary_active_armed_forces                          :integer          default(0), not null
#  primary_birth_date                                   :date
#  primary_consented_to_service                         :integer          default("unfilled"), not null
#  primary_consented_to_service_at                      :datetime
#  primary_consented_to_service_ip                      :inet
#  primary_first_name                                   :string
#  primary_ip_pin                                       :text
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
#  spouse_ip_pin                                        :text
#  spouse_issued_identity_pin                           :integer          default(0), not null
#  spouse_last_four_ssn                                 :text
#  spouse_last_name                                     :string
#  spouse_middle_initial                                :string
#  spouse_prior_year_agi_amount                         :integer
#  spouse_prior_year_signature_pin                      :string
#  spouse_signature_pin                                 :text
#  spouse_signature_pin_at                              :datetime
#  spouse_ssn                                           :text
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
#  created_at                                           :datetime
#  updated_at                                           :datetime
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
#  index_arcint_2021_on_canonical_email_address                (canonical_email_address)
#  index_arcint_2021_on_client_id                              (client_id)
#  index_arcint_2021_on_completed_at                           (completed_at) WHERE (completed_at IS NOT NULL)
#  index_arcint_2021_on_email_address                          (email_address)
#  index_arcint_2021_on_email_domain                           (email_domain)
#  index_arcint_2021_on_needs_to_flush_searchable_data_set_at  (needs_to_flush_searchable_data_set_at) WHERE (needs_to_flush_searchable_data_set_at IS NOT NULL)
#  index_arcint_2021_on_phone_number                           (phone_number)
#  index_arcint_2021_on_probable_previous_year_intake_fields   (primary_birth_date,primary_first_name,primary_last_name)
#  index_arcint_2021_on_searchable_data                        (searchable_data) USING gin
#  index_arcint_2021_on_sms_phone_number                       (sms_phone_number)
#  index_arcint_2021_on_spouse_email_address                   (spouse_email_address)
#  index_arcint_2021_on_type                                   (type)
#  index_arcint_2021_on_vita_partner_id                        (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
require "rails_helper"

describe Archived::Intake2021 do
  context "custom readers for encrypted attrs cutover" do
    describe "#primary_ssn" do
      let!(:intake) { create :archived_2021_ctc_intake, attr_encrypted_primary_ssn: "123456789", primary_ssn: nil }

      it "is an encrypted attribute" do
        intake.update(primary_ssn: "123456789") # only true if reading from the rails encrypts attribute
        expect(intake.encrypted_attribute?(:primary_ssn)).to eq true
      end

      it "can read primary_ssn when there is only an old encrypted value" do
        expect(intake.attr_encrypted_primary_ssn).to eq "123456789"
        expect(intake.read_attribute(:primary_ssn)).to eq nil
        expect(intake.primary_ssn).to eq "123456789"
      end

      it "can write primary_ssn to the new encrypted field" do
        intake.update(primary_ssn: "123456898")
        expect(intake.attr_encrypted_primary_ssn).to eq "123456789"
        expect(intake.primary_ssn).to eq "123456898"
      end
    end

    describe "#spouse_ssn" do
      let!(:intake) { create :archived_2021_ctc_intake, attr_encrypted_spouse_ssn: "123456789", spouse_ssn: nil }

      it "is an encrypted attribute" do
        intake.update(spouse_ssn: "123456789")
        expect(intake.encrypted_attribute?(:spouse_ssn)).to eq true
      end

      it "can read spouse_ssn when there is only an old encrypted value" do
        expect(intake.attr_encrypted_spouse_ssn).to eq "123456789"
        expect(intake.read_attribute(:spouse_ssn)).to eq nil
        expect(intake.spouse_ssn).to eq "123456789"
      end

      it "can write spouse_ssn to the new encrypted field" do
        intake.update(spouse_ssn: "123456898")
        expect(intake.attr_encrypted_spouse_ssn).to eq "123456789"
        expect(intake.spouse_ssn).to eq "123456898"
      end
    end

    describe "#primary_last_four_ssn" do
      let!(:intake) { create :archived_2021_ctc_intake, primary_last_four_ssn: "1234" }

      it "is an encrypted attribute" do
        expect(intake.encrypted_attribute?(:primary_last_four_ssn)).to eq true
      end

      it "must be written to directly" do
        expect(intake.read_attribute(:primary_last_four_ssn)).to eq "1234"
        expect(intake.primary_last_four_ssn).to eq "1234"
      end
    end

    describe "#spouse_last_four_ssn" do
      let!(:intake) { create :archived_2021_ctc_intake, spouse_last_four_ssn: "6787" }

      it "is an encrypted attribute" do
        expect(intake.encrypted_attribute?(:spouse_last_four_ssn)).to eq true
      end

      it "updates when written to directly" do
        expect(intake.spouse_last_four_ssn).to eq "6787"
        expect(intake.read_attribute(:spouse_last_four_ssn)).to eq "6787"
      end
    end

    describe "#bank_name" do
      let!(:intake) { create :archived_2021_ctc_intake, attr_encrypted_bank_name: "Bank of Two Melons", bank_name: nil }

      it "is not an encrypted attribute" do
        expect(intake.encrypted_attribute?(:bank_name)).to eq false
      end

      it "can read bank_name when there is only an old encrypted value" do
        expect(intake.bank_name).to eq "Bank of Two Melons"
        expect(intake.read_attribute(:bank_name)).to eq nil
      end

      it "can write and read from new bank_account attribute without affecting old column" do
        intake.update(bank_name: "Bank of Twelve Cherries")
        expect(intake.bank_name).to eq "Bank of Twelve Cherries"
        expect(intake.read_attribute(:bank_name)).to eq "Bank of Twelve Cherries"
        expect(intake.attr_encrypted_bank_name).to eq "Bank of Two Melons"
      end
    end

    describe "#bank_routing_number" do
      let!(:intake) { create :archived_2021_ctc_intake, attr_encrypted_bank_routing_number: "123456878", bank_routing_number: nil }

      it "is not an encrypted attribute" do
        intake.update(bank_routing_number: "123457898")
        expect(intake.encrypted_attribute?(:bank_routing_number)).to eq false
      end

      it "can read routing_number when there is only an old encrypted value" do
        expect(intake.bank_routing_number).to eq "123456878"
        expect(intake.read_attribute(:bank_routing_number)).to eq nil
      end

      it "can write and read from new bank_account attribute without affecting old column" do
        intake.update(bank_routing_number: "123456877")
        expect(intake.bank_routing_number).to eq "123456877"
        expect(intake.read_attribute(:bank_routing_number)).to eq "123456877"
        expect(intake.attr_encrypted_bank_routing_number).to eq "123456878"
      end
    end

    describe "#bank_account_number" do
      let!(:intake) { create :archived_2021_ctc_intake, attr_encrypted_bank_account_number: "123456878", bank_account_number: nil }

      it "is not an encrypted attribute" do
        intake.update(bank_account_number: "123457898")
        expect(intake.encrypted_attribute?(:bank_routing_number)).to eq false
      end

      it "can read account_number when there is only an old encrypted value" do
        expect(intake.bank_account_number).to eq "123456878"
        expect(intake.read_attribute(:bank_account_number)).to eq nil
      end

      it "can write and read from new bank_account attribute without affecting old column" do
        intake.update(bank_account_number: "123456877")
        expect(intake.bank_account_number).to eq "123456877"
        expect(intake.read_attribute(:bank_account_number)).to eq "123456877"
        expect(intake.attr_encrypted_bank_account_number).to eq "123456878"
      end
    end

    describe "#primary_ip_pin" do
      let!(:intake) { create :archived_2021_ctc_intake, attr_encrypted_primary_ip_pin: "12345", primary_ip_pin: nil }

      it "is an encrypted attribute" do
        intake.update(primary_ip_pin: "12345") # only true if reading from the rails encrypts attribute
        expect(intake.encrypted_attribute?(:primary_ip_pin)).to eq true
      end

      it "can read primary_ip_pin when there is only an old encrypted value" do
        expect(intake.attr_encrypted_primary_ip_pin).to eq "12345"
        expect(intake.read_attribute(:primary_ip_pin)).to eq nil
        expect(intake.primary_ip_pin).to eq "12345"
      end

      it "can write primary_ip_pin to the new encrypted field" do
        intake.update(primary_ip_pin: "11125")
        expect(intake.attr_encrypted_primary_ip_pin).to eq "12345"
        expect(intake.primary_ip_pin).to eq "11125"
      end
    end

    describe "#spouse_ip_pin" do
      let!(:intake) { create :archived_2021_ctc_intake, attr_encrypted_spouse_ip_pin: "123456", spouse_ip_pin: nil }

      it "is an encrypted attribute" do
        intake.update(spouse_ip_pin: "123456") # only true if reading from the rails encrypts attribute
        expect(intake.encrypted_attribute?(:spouse_ip_pin)).to eq true
      end

      it "can read spouse_ip_pin when there is only an old encrypted value" do
        expect(intake.attr_encrypted_spouse_ip_pin).to eq "123456"
        expect(intake.read_attribute(:spouse_ip_pin)).to eq nil
        expect(intake.spouse_ip_pin).to eq "123456"
      end

      it "can write spouse_ip_pin to the new encrypted field" do
        intake.update(spouse_ip_pin: "111256")
        expect(intake.attr_encrypted_spouse_ip_pin).to eq "123456"
        expect(intake.spouse_ip_pin).to eq "111256"
      end
    end

    describe "#spouse_signature_pin" do
      let!(:intake) { create :archived_2021_ctc_intake, attr_encrypted_spouse_signature_pin: "12345", spouse_signature_pin: nil }

      it "is an encrypted attribute" do
        intake.update(spouse_signature_pin: "12345") # only true if reading from the rails encrypts attribute
        expect(intake.encrypted_attribute?(:spouse_signature_pin)).to eq true
      end

      it "can read spouse_signature_pin when there is only an old encrypted value" do
        expect(intake.attr_encrypted_spouse_signature_pin).to eq "12345"
        expect(intake.read_attribute(:spouse_signature_pin)).to eq nil
        expect(intake.spouse_signature_pin).to eq "12345"
      end

      it "can write spouse_signature_pin to the new encrypted field" do
        intake.update(spouse_signature_pin: "11125")
        expect(intake.attr_encrypted_spouse_signature_pin).to eq "12345"
        expect(intake.spouse_signature_pin).to eq "11125"
      end
    end

    describe "#primary_signature_pin" do
      let!(:intake) { create :archived_2021_ctc_intake, attr_encrypted_primary_signature_pin: "12345", primary_signature_pin: nil }

      it "is an encrypted attribute" do
        intake.update(primary_signature_pin: "12565") # only true if reading from the rails encrypts attribute
        expect(intake.encrypted_attribute?(:primary_signature_pin)).to eq true
      end

      it "can read primary_signature_pin when there is only an old encrypted value" do
        expect(intake.attr_encrypted_primary_signature_pin).to eq "12345"
        expect(intake.read_attribute(:primary_signature_pin)).to eq nil
        expect(intake.primary_signature_pin).to eq "12345"
      end

      it "can write primary_signature_pin to the new encrypted field" do
        intake.update(primary_signature_pin: "11125")
        expect(intake.attr_encrypted_primary_signature_pin).to eq "12345"
        expect(intake.primary_signature_pin).to eq "11125"
      end
    end
  end
end
