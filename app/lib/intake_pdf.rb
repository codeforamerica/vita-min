class IntakePdf
  include PdfHelper

  def source_pdf_name
    "f13614c"
  end

  def initialize(intake)
    @intake = intake
    @primary = intake.primary_user
    @spouse = intake.spouse
    @dependents = intake.dependents
  end

  def hash_for_pdf
    answers = {
      street_address: @intake.street_address,
      city: @intake.city,
      state: @intake.state&.upcase,
      zip_code: @intake.zip_code,
      multistate: yes_no_unfilled_to_radio(@intake.multiple_states),
      never_married: yes_no_unfilled_to_opposite_checkbox(@intake.ever_married),
      married: yes_no_unfilled_to_checkbox(@intake.married),
      divorced: yes_no_unfilled_to_checkbox(@intake.divorced),
      widowed: yes_no_unfilled_to_checkbox(@intake.widowed),
      separated: yes_no_unfilled_to_checkbox(@intake.separated),
      lived_with_spouse: yes_no_unfilled_to_radio(@intake.lived_with_spouse),
      widowed_date: @intake.widowed_year,
      divorced_date: @intake.divorced_year,
      separated_date: @intake.separated_year,
      had_wages: yes_no_unfilled_to_checkbox(@intake.had_wages),
      job_count: @intake.job_count == 5 ? "5 or more" : @intake.job_count,
      had_tips: yes_no_unfilled_to_checkbox(@intake.had_tips),
      had_retirement_income: yes_no_unfilled_to_checkbox(@intake.had_retirement_income),
      had_social_security_income: yes_no_unfilled_to_checkbox(@intake.had_social_security_income),
      had_unemployment_income: yes_no_unfilled_to_checkbox(@intake.had_unemployment_income),
      had_disability_income: yes_no_unfilled_to_checkbox(@intake.had_disability_income),
      had_interest_income: yes_no_unfilled_to_checkbox(@intake.had_interest_income),
      had_asset_sale_income: yes_no_unfilled_to_checkbox(@intake.had_asset_sale_income),
      reported_asset_sale_loss: yes_no_unfilled_to_checkbox(@intake.reported_asset_sale_loss),
      received_alimony: yes_no_unfilled_to_checkbox(@intake.received_alimony),
      had_rental_income: yes_no_unfilled_to_checkbox(@intake.had_rental_income),
      had_farm_income: yes_no_unfilled_to_checkbox(@intake.had_farm_income),
      had_gambling_income: yes_no_unfilled_to_checkbox(@intake.had_gambling_income),
      had_local_tax_refund: yes_no_unfilled_to_checkbox(@intake.had_local_tax_refund),
      had_self_employment_income: yes_no_unfilled_to_checkbox(@intake.had_self_employment_income),
      reported_self_employment_loss: yes_no_unfilled_to_checkbox(@intake.reported_self_employment_loss),
      had_other_income: yes_no_unfilled_to_checkbox(@intake.had_other_income),
      other_income_types: @intake.other_income_types,
      paid_mortgage_interest: yes_no_unfilled_to_checkbox(@intake.paid_mortgage_interest),
      paid_local_tax: yes_no_unfilled_to_checkbox(@intake.paid_local_tax),
      paid_medical_expenses: yes_no_unfilled_to_checkbox(@intake.paid_medical_expenses),
      paid_charitable_contributions: yes_no_unfilled_to_checkbox(@intake.paid_charitable_contributions),
      paid_student_loan_interest: yes_no_unfilled_to_checkbox(@intake.paid_student_loan_interest),
      paid_dependent_care: yes_no_unfilled_to_checkbox(@intake.paid_dependent_care),
      paid_retirement_contributions: yes_no_unfilled_to_checkbox(@intake.paid_retirement_contributions),
      paid_school_supplies: yes_no_unfilled_to_checkbox(@intake.paid_school_supplies),
      paid_alimony: yes_no_unfilled_to_checkbox(@intake.paid_alimony),
      had_student_in_family: yes_no_unfilled_to_checkbox(@intake.had_student_in_family),
      sold_a_home: yes_no_unfilled_to_checkbox(@intake.sold_a_home),
      had_hsa: yes_no_unfilled_to_checkbox(@intake.had_hsa),
      bought_health_insurance: yes_no_unfilled_to_checkbox(@intake.bought_health_insurance),
      received_homebuyer_credit: yes_no_unfilled_to_checkbox(@intake.received_homebuyer_credit),
      had_debt_forgiven: yes_no_unfilled_to_checkbox(@intake.had_debt_forgiven),
      had_disaster_loss: yes_no_unfilled_to_checkbox(@intake.had_disaster_loss),
      adopted_child: yes_no_unfilled_to_checkbox(@intake.adopted_child),
      had_tax_credit_disallowed: yes_no_unfilled_to_checkbox(@intake.had_tax_credit_disallowed),
      received_irs_letter: yes_no_unfilled_to_checkbox(@intake.received_irs_letter),
      made_estimated_tax_payments: yes_no_unfilled_to_checkbox(@intake.made_estimated_tax_payments),
      additional_info: @intake.additional_info,
    }
    answers.merge!(demographic_info) if @intake.demographic_questions_opt_in_yes?
    answers.merge!(primary_info) if @primary.present?
    answers.merge!(spouse_info) if @spouse.present?
    answers.merge!(dependents_info) if @dependents.present?
    answers
  end

  def primary_info
    {
      first_name: @primary.first_name,
      last_name: @primary.last_name,
      date_of_birth: strftime_date(@primary.parsed_birth_date),
      phone_number: @primary.formatted_phone_number,
      email: @primary.email,
    }
  end

  def spouse_info
    {
      spouse_first_name: @spouse.first_name,
      spouse_last_name: @spouse.last_name,
      spouse_date_of_birth: strftime_date(@spouse.parsed_birth_date),
    }
  end

  def dependents_info
    answers = {}
    @dependents.first(4).each_with_index do |dependent, index|
      prefix = "dependent_#{index + 1}"
      {
        name: dependent.full_name,
        date_of_birth: strftime_date(dependent.birth_date),
        relationship: dependent.relationship,
        months_in_home: dependent.months_in_home.to_s,
        disabled: yes_no_unfilled_to_YN(dependent.disabled),
        north_american_resident: yes_no_unfilled_to_YN(dependent.north_american_resident),
        on_visa: yes_no_unfilled_to_YN(dependent.on_visa),
        student: yes_no_unfilled_to_YN(dependent.was_student),
        marital_status: married_to_SM(dependent.was_married),
      }.each do |key, value|
        full_key = "#{prefix}_#{key}".to_sym
        answers[full_key] = value
      end
    end
    answers
  end

  def demographic_info
    {
      english_conversation_very_well: bool_checkbox(@intake.demographic_english_conversation_very_well?),
      english_conversation_well: bool_checkbox(@intake.demographic_english_conversation_well?),
      english_conversation_not_well: bool_checkbox(@intake.demographic_english_conversation_not_well?),
      english_conversation_not_at_all: bool_checkbox(@intake.demographic_english_conversation_not_at_all?),
      english_conversation_no_answer: bool_checkbox(@intake.demographic_english_conversation_prefer_not_to_answer?),
      english_newspaper_very_well: bool_checkbox(@intake.demographic_english_reading_very_well?),
      english_newspaper_well: bool_checkbox(@intake.demographic_english_reading_well?),
      english_newspaper_not_well: bool_checkbox(@intake.demographic_english_reading_not_well?),
      english_newspaper_not_at_all: bool_checkbox(@intake.demographic_english_reading_not_at_all?),
      english_newspaper_no_answer: bool_checkbox(@intake.demographic_english_reading_prefer_not_to_answer?),
      anyone_disabled_yes: bool_checkbox(@intake.demographic_disability_yes?),
      anyone_disabled_no: bool_checkbox(@intake.demographic_disability_no?),
      anyone_disabled_no_answer: bool_checkbox(@intake.demographic_disability_prefer_not_to_answer?),
      anyone_veteran_yes: bool_checkbox(@intake.demographic_veteran_yes?),
      anyone_veteran_no: bool_checkbox(@intake.demographic_veteran_no?),
      anyone_veteran_no_answer: bool_checkbox(@intake.demographic_veteran_prefer_not_to_answer?),
      race_american_indian_alaskan_native: bool_checkbox(@intake.demographic_primary_american_indian_alaska_native),
      race_asian: bool_checkbox(@intake.demographic_primary_asian),
      race_black_african_american: bool_checkbox(@intake.demographic_primary_black_african_american),
      race_native_hawaiian_pacific_islander: bool_checkbox(@intake.demographic_primary_native_hawaiian_pacific_islander),
      race_white: bool_checkbox(@intake.demographic_primary_white),
      race_no_answer: bool_checkbox(@intake.demographic_primary_prefer_not_to_answer_race),
      spouse_race_american_indian_alaskan_native: bool_checkbox(@intake.demographic_spouse_american_indian_alaska_native),
      spouse_race_asian: bool_checkbox(@intake.demographic_spouse_asian),
      spouse_race_black_african_american: bool_checkbox(@intake.demographic_spouse_black_african_american),
      spouse_race_native_hawaiian_pacific_islander: bool_checkbox(@intake.demographic_spouse_native_hawaiian_pacific_islander),
      spouse_race_white: bool_checkbox(@intake.demographic_spouse_white),
      spouse_race_no_answer: bool_checkbox(@intake.demographic_spouse_prefer_not_to_answer_race),
      ethnicity_hispanic: bool_checkbox(@intake.demographic_primary_ethnicity_hispanic_latino?),
      ethnicity_not_hispanic: bool_checkbox(@intake.demographic_primary_ethnicity_not_hispanic_latino?),
      ethnicity_no_answer: bool_checkbox(@intake.demographic_primary_ethnicity_prefer_not_to_answer?),
      spouse_ethnicity_hispanic: bool_checkbox(@intake.demographic_spouse_ethnicity_hispanic_latino?),
      spouse_ethnicity_not_hispanic: bool_checkbox(@intake.demographic_spouse_ethnicity_not_hispanic_latino?),
      spouse_ethnicity_no_answer: bool_checkbox(@intake.demographic_spouse_ethnicity_prefer_not_to_answer?),
    }
  end

  private

  def yes_no_unfilled_to_YN(yes_no_unfilled)
    {
      "yes" => "Y",
      "no" => "N",
      "unfilled" => ""
    }[yes_no_unfilled]
  end

  def married_to_SM(was_married_yes_no_unfilled)
    {
      "yes" => "M",
      "no" => "S",
      "unfilled" => ""
    }[was_married_yes_no_unfilled]
  end
end