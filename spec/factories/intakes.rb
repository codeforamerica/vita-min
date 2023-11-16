# Annotate struggles with STI here so we're skipping it so `annotate --frozen` will be clean
# -*- SkipSchemaAnnotations
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
      build_list(:dependent, evaluator.dependent_count, intake: intake)
    end
  end

  generate_fake_ssn = -> do
    # 0s in 4th and 5th position are required for IRS test submissions
    attempts = 0
    random_ssn = ''
    until SocialSecurityNumberValidator::LOOSE_SSN_REGEX.match(random_ssn) do
      attempts += 1
      raise StandardError.new("Couldn't make a good fake SSN, last try was #{random_ssn}") if attempts > 5
      random_ssn = "8#{rand(10..99)}00#{rand(1000..9999)}"
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
      build_list(:document, evaluator.dependent_count, intake: intake)
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

  trait :claiming_eitc do
    claim_eitc { 'yes' }
    exceeded_investment_income_limit { 'no' }
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
    sold_a_home { "no" }
    had_hsa { "yes" }
    bought_marketplace_health_insurance { "no" }
    received_homebuyer_credit { "yes" }
    had_debt_forgiven { "no" }
    had_disaster_loss { "yes" }
    adopted_child { "no" }
    had_tax_credit_disallowed { "no" }
    received_irs_letter { "no" }
    made_estimated_tax_payments { "no" }
    additional_info { "This is some critical information I'd like my tax preparer to know during intake process." }
    primary_us_citizen { "yes" }
    spouse_us_citizen { "no" }
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
    locale { ["en", "es"].sample }
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
    routing_value { "az" }
    routing_criteria { "state" }
    job_count { [1, 2, 3].sample }
    preferred_interview_language { ["en", "es"].sample }
    completed_at { 1.week.ago }
    demographic_primary_american_indian_alaska_native { true }
    demographic_primary_black_african_american { true }
    demographic_primary_native_hawaiian_pacific_islander { true }
    demographic_primary_asian { true }
    demographic_primary_white { true }
    demographic_primary_prefer_not_to_answer_race { false }
    demographic_english_reading { "well" }
    demographic_english_conversation { "not_well" }
    bought_energy_efficient_items { "unfilled" } # no default value in db for this enum.
    bank_account_type { "checking" }
    refund_payment_method { "check" }
    triage_income_level { "zero" }
    triage_filing_status { "single" }
    triage_filing_frequency { "some_years" }

    after(:build) do |intake|
      # default any unsupplied enum values to 'no' if possible
      hub_only_enums = ["presidential_campaign_fund_donation"]
      intake.class.defined_enums.except(*hub_only_enums).each_key do |key|
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
    product_year { 2022 }
    sequence(:visitor_id) { |n| "visitor_id_#{n}" }
    primary_birth_date { Date.new(1988, 12, 20) }
    spouse_birth_date { Date.new(1976, 12, 20) }
    sms_phone_number { "+15125551234" }
    sequence(:email_address) { |n| "mango#{n}@example.com" }
    association :client, factory: :ctc_client
    needs_to_flush_searchable_data_set_at { 1.minute.ago }
    eip1_amount_received { 1000 }
    eip2_amount_received { 1000 }
    eip3_amount_received { 1000 }
    advance_ctc_amount_received { 0 }
    primary_tin_type { "ssn" }
    current_step { "/en/questions/overview" }
  end

  factory :intake, class: Intake::GyrIntake do
    product_year { Rails.configuration.product_year }
    had_wages { :unfilled }
    client { build :client, consented_to_service_at: nil }
    sequence(:visitor_id) { |n| "visitor_id_#{n}" }
    needs_to_flush_searchable_data_set_at { 1.minute.ago }
    current_step { "/en/questions/overview" }
  end
end
