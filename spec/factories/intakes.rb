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
#  hashed_primary_ssn                                   :string
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
#  used_itin_certifying_acceptance_agent                :boolean          default(FALSE), not null
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
#  index_intakes_on_hashed_primary_ssn                     (hashed_primary_ssn)
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
module IntakeFactoryHelpers
  def self.roman_numerals(n)
    letter_values = {
      1000 => "M",
      900 => "CM",
      500 => "D",
      400 => "CD",
      100 => "C",
      90 => "XC",
      50 => "L",
      40 => "XL",
      10 => "X",
      9 => "IX",
      5 => "V",
      4 => "IV",
      1 => "I",
    }

    roman = ""
    letter_values.each do |value, letter|
      roman << letter*(n / value)
      n = n % value
    end
    return roman
  end
end

FactoryBot.define do
  trait :primary_consented do
    primary_consented_to_service_at { 2.weeks.ago }
    primary_consented_to_service { "yes" }
    primary_consented_to_service_ip { "1.1.1.1" } # IRS approved IP address
  end

  trait :with_banking_details do
    bank_name { "Self-help United" }
    bank_routing_number { "12345678" }
    bank_account_number { "87654321" }
    bank_account_type { "checking" }
  end

  trait :with_bank_account do
    bank_account
  end

  trait :with_dependents do
    transient do
      dependent_count { 1 }
    end

    after(:build) do |intake, evaluator|
      create_list(:dependent, evaluator.dependent_count, intake: intake)
    end
  end

  generate_fake_ssn = -> do
    # 0s in 4th and 5th position are required for IRS test submissions
    attempts = 0
    random_ssn = ''
    until SocialSecurityNumberValidator::LOOSE_SSN_REGEX.match(random_ssn) do
      attempts += 1
      raise StandardError.new("Couldn't make a good fake SSN, last try was #{random_ssn}") if attempts > 5
      random_ssn = "8#{Faker::Number.number(digits: 2)}00#{Faker::Number.number(digits: 4)}"
    end

    random_ssn
  end

  trait :with_ssns do
    primary_ssn { generate_fake_ssn.call }
    spouse_ssn { generate_fake_ssn.call }
  end

  trait :with_documents do
    transient do
      document_count { 1 }
    end

    after(:build) do |intake, evaluator|
      create_list(:document, evaluator.dependent_count, intake: intake)
    end
  end

  trait :with_contact_info do
    preferred_name { "Cherry" }
    primary_first_name { "Cher" }
    sequence(:primary_last_name) { |n| "O'Cherimoya #{IntakeFactoryHelpers.roman_numerals(n)}" }
    phone_number { "+14155551212" }
    sms_phone_number { "+14155551212" }
    sequence(:email_address) { |n| "cher_#{IntakeFactoryHelpers.roman_numerals(n)}@example.com" }
    email_notification_opt_in { "yes" }
  end

  trait :with_address do
    city { "San Francisco" }
    state { "CA" }
    zip_code { "94103" }
    street_address { "972 Mission St" }
  end

  trait :with_deterministic_yes_no_answers do
    married { "yes" }
    divorced { "yes" }
    divorced_year { "2018" }
    ever_married { "yes" }
    lived_with_spouse { "yes" }
    widowed { "no" }
    widowed_year { "2016" }
    separated { "yes" }
    separated_year { "2017" }
    had_wages { "yes" }
    job_count { 6 }
    had_tips { "yes" }
    had_retirement_income { "no" }
    had_social_security_income { "no" }
    had_unemployment_income { "yes" }
    had_disability_income { "yes" }
    had_interest_income { "no" }
    had_asset_sale_income { "yes" }
    multiple_states { "yes" }
    reported_asset_sale_loss { "no" }
    received_alimony { "yes" }
    had_rental_income { "no" }
    had_farm_income { "yes" }
    had_gambling_income { "yes" }
    had_local_tax_refund { "yes" }
    had_self_employment_income { "yes" }
    reported_self_employment_loss { "no" }
    had_other_income { "yes" }
    other_income_types { "Doordash, Babysitting" }
    paid_mortgage_interest { "yes" }
    paid_local_tax { "yes" }
    paid_medical_expenses { "yes" }
    paid_charitable_contributions { "yes" }
    paid_student_loan_interest { "yes" }
    paid_dependent_care { "yes" }
    paid_retirement_contributions { "yes" }
    paid_school_supplies { "unfilled" }
    paid_alimony { "no" }
    had_student_in_family { "yes" }
    sold_a_home { "no" }
    had_hsa { "yes" }
    bought_health_insurance { "no" }
    received_homebuyer_credit { "yes" }
    had_debt_forgiven { "no" }
    had_disaster_loss { "yes" }
    adopted_child { "no" }
    had_tax_credit_disallowed { "no" }
    received_irs_letter { "no" }
    made_estimated_tax_payments { "no" }
    additional_info { "This is some critical information I'd like my tax preparer to know during intake process." }
    was_on_visa { "yes" }
    spouse_was_on_visa { "no" }
    was_full_time_student { "no" }
    spouse_was_full_time_student { "yes" }
    was_blind { "yes" }
    spouse_was_blind { "yes" }
    had_disability { "yes" }
    spouse_had_disability { "yes" }
    issued_identity_pin { "yes" }
    spouse_issued_identity_pin { "no" }
    refund_payment_method { "direct_deposit" }
    savings_split_refund { "yes" }
    savings_purchase_bond { "yes" }
    balance_pay_from_bank { "yes" }
    demographic_questions_opt_in { "yes" }
  end

  trait :filled_out_ctc do
    primary_first_name { "Yayoi" }
    primary_last_name { "Kusama" }
    primary_ssn { '111-22-3333' }
    primary_birth_date { Date.new(1929, 3, 22) }
    preferred_name { "Y Kusama" }
    preferred_interview_language { "en" }
    email_address { "yayoi@kusama.com" }
    phone_number { "+15005550006" }
    sms_phone_number { "+15005550006" }
    street_address { "2900 Southern Blvd" }
    city { "Bronx" }
    state_of_residence { "NY" }
    zip_code { "10458" }
    sms_notification_opt_in { "yes" }
    email_notification_opt_in { "no" }
    spouse_first_name { "Eva" }
    spouse_last_name { "Hesse" }
    spouse_email_address { "eva@hesse.com" }
    spouse_ssn { '111-22-3333' }
    spouse_birth_date { Date.new(1929, 9, 2)}
    timezone { "America/Chicago" }
    signature_method { "online" }
    refund_payment_method { "check" }
    bank_account_type { "checking" }
    with_passport_photo_id { "1" }
    with_itin_taxpayer_id { "1" }
    navigator_name { "Terry Taxseason" }
    navigator_has_verified_client_identity { "1" }
  end

  trait :filled_out do
    document_count  { [1, 2, 3].sample }
    dependent_count { [1, 2, 3].sample }
    with_dependents
    with_documents
    vita_partner { build(:organization) }
    locale { ["en", "es"].sample }
    source { vita_partner.source_parameters.first&.code || "none" }
    referrer { "/" }
    primary_ssn { "123456789" }
    primary_tin_type { "ssn" }
    spouse_ssn { "123456789" }
    spouse_tin_type { "ssn" }
    primary_birth_date { Date.new(1979, 12, 24) }
    spouse_birth_date { Date.new(1983, 11, 23) }
    street_address { "123 Cherry Lane" }
    zip_code { "94103" }
    city { "San Francisco" }
    state { "CA" }
    state_of_residence { state }
    vita_partner_name { vita_partner.name }
    routing_value { "az" }
    routing_criteria { "state" }
    job_count { [1, 2, 3].sample }
    preferred_interview_language { ["en", "es"].sample }
    primary_consented_to_service_at { 2.weeks.ago }
    completed_at { 1.week.ago }
    demographic_primary_american_indian_alaska_native { true }
    demographic_primary_black_african_american { true }
    demographic_primary_native_hawaiian_pacific_islander { true }
    demographic_primary_asian { true }
    demographic_primary_white { true }
    demographic_primary_prefer_not_to_answer_race { true }
    demographic_english_reading { "well" }
    demographic_english_conversation { "not_well" }
    bought_energy_efficient_items { "unfilled" } # no default value in db for this enum.
    bank_account_type { "checking" }
    refund_payment_method { "check" }

    after(:build) do |intake|
      # default any unsupplied enum values to 'no' if possible
      intake.class.defined_enums.each_key do |key|
        if intake[key] == "unfilled"
          enum_keys = intake.class.send(key.pluralize).keys
          default_choices = %w(no prefer_not_to_answer neutral)
          default_choice = enum_keys.find { |k| k.in?(default_choices) }
          if default_choice
            intake[key] = default_choice
          else
            raise "Didn't know what to do for enum #{key} - we usually default to [#{default_choices.join(' or ')}] but that value was not available"
          end
        end
      end
    end
  end

  factory :ctc_intake, class: Intake::CtcIntake do
    sequence(:visitor_id) { |n| "visitor_id_#{n}" }
    primary_birth_date { Date.new(1988, 12, 20) }
    spouse_birth_date { Date.new(1976, 12, 20) }
    sms_phone_number { "+15125551234" }
    sequence(:email_address) { |n| "mango#{n}@example.com" }
    association :client, factory: :ctc_client
    needs_to_flush_searchable_data_set_at { 1.minute.ago }
    eip1_amount_received { 1000 }
    eip2_amount_received { 1000 }
    primary_tin_type { "ssn" }
    current_step { "/en/questions/overview" }
  end

  factory :intake, class: Intake::GyrIntake do
    had_wages { :unfilled }
    client
    sequence(:visitor_id) { |n| "visitor_id_#{n}" }
    needs_to_flush_searchable_data_set_at { 1.minute.ago }
    current_step { "/en/questions/overview" }
  end
end
