class IntakePdf
  include PdfHelper

  def source_pdf_name
    "f13614c-TY2020"
  end

  def initialize(intake)
    @intake = intake
    @dependents = intake.dependents
  end

  def hash_for_pdf
    answers = {
      street_address: @intake.street_address,
      city: @intake.city,
      state: @intake.state&.upcase,
      zip_code: @intake.zip_code,
      claimed_by_another: @intake.claimed_by_another,
      never_married: yes_no_unfilled_to_opposite_checkbox_0(@intake.ever_married),
      married: yes_no_unfilled_to_checkbox_0(@intake.married),
      divorced: yes_no_unfilled_to_checkbox_0(@intake.divorced),
      widowed: yes_no_unfilled_to_checkbox_0(@intake.widowed),
      legally_separated: yes_no_unfilled_to_checkbox_0(@intake.separated),
      lived_with_spouse: @intake.lived_with_spouse,
      married_in_2020: nil,
      widowed_date: @intake.widowed_year,
      divorced_date: @intake.divorced_year,
      separated_date: @intake.separated_year,
      had_wages: @intake.had_wages,
      job_count: @intake.job_count.to_s,
      had_tips: @intake.had_tips,
      had_scholarships: nil,
      had_unreported_work_income: nil,
      had_retirement_income: @intake.had_retirement_income,
      had_social_security_income: @intake.had_social_security_income,
      had_unemployment_income: @intake.had_unemployment_income,
      had_disability_income: @intake.had_disability_income,
      had_interest_income: @intake.had_interest_income,
      had_asset_sale_income_loss: collective_yes_no_unsure(@intake.had_asset_sale_income, @intake.reported_asset_sale_loss),
      # reported_asset_sale_loss: @intake.reported_asset_sale_loss,
      received_alimony: @intake.received_alimony,
      had_rental_income: @intake.had_rental_income,
      # had_gambling_income: @intake.had_gambling_income,
      had_local_tax_income: @intake.had_local_tax_refund,
      had_self_employment_income: @intake.had_self_employment_income,
      # reported_self_employment_loss: @intake.reported_self_employment_loss,
      had_other_income: collective_yes_no_unsure(@intake.had_other_income, @intake.had_gambling_income),
      other_income_types: @intake.other_income_types,
      paid_local_tax: yes_no_unfilled_to_checkbox_0(@intake.paid_local_tax),
      paid_mortgage_interest: yes_no_unfilled_to_checkbox_0(@intake.paid_mortgage_interest),
      paid_medical_expenses: yes_no_unfilled_to_checkbox_0(@intake.paid_medical_expenses),
      paid_charitable_contributions: yes_no_unfilled_to_checkbox_0(@intake.paid_charitable_contributions),
      had_misc_expenses: collective_yes_no_unsure(@intake.paid_local_tax, @intake.paid_mortgage_interest, @intake.paid_medical_expenses, @intake.paid_charitable_contributions),
      paid_student_loan_interest: @intake.paid_student_loan_interest,
      paid_dependent_care: @intake.paid_dependent_care,
      paid_retirement_contributions: @intake.paid_retirement_contributions,
      paid_into_traditional_ira: yes_no_unfilled_to_checkbox_0(nil),
      paid_into_401k: yes_no_unfilled_to_checkbox_0(nil),
      paid_into_other_retirement_account: yes_no_unfilled_to_checkbox_0(nil),
      paid_into_roth_ira: yes_no_unfilled_to_checkbox_0(nil),
      paid_school_supplies: @intake.paid_school_supplies,
      paid_alimony: @intake.paid_alimony,
      have_alimony_recipient_ssn: nil,
      paid_post_secondary_expenses: @intake.had_student_in_family,
      # sold_a_home: @intake.sold_a_home,
      had_hsa: @intake.had_hsa,
      bought_health_insurance: @intake.bought_health_insurance,
      bought_energy_efficient_items: @intake.bought_energy_efficient_items || "unfilled", # no default in db
      received_homebuyer_credit: @intake.received_homebuyer_credit,
      had_debt_forgiven: @intake.had_debt_forgiven,
      had_disaster_loss: @intake.had_disaster_loss,
      adopted_child: @intake.adopted_child,
      had_tax_credit_disallowed: @intake.had_tax_credit_disallowed,
      received_irs_letter: @intake.received_irs_letter,
      made_estimated_tax_payments: @intake.made_estimated_tax_payments,
      additional_comments: "#{@intake.additional_info} #{@intake.final_info}",
      student: @intake.was_full_time_student,
      spouse_student: @intake.spouse_was_full_time_student,
      blind: @intake.was_blind,
      spouse_blind: @intake.spouse_was_blind,
      is_disabled: @intake.had_disability,
      spouse_is_disabled: @intake.spouse_had_disability,
      is_citizen: nil,
      spouse_is_citizen: nil,
      issued_pin: collective_yes_no_unsure(@intake.issued_identity_pin, @intake.spouse_issued_identity_pin),
      direct_deposit: determine_direct_deposit(@intake),
      savings_split_refund: @intake.savings_split_refund,
      savings_purchase_bond: @intake.savings_purchase_bond,
      balance_due_transfer: @intake.balance_pay_from_bank,
      spouse_was_on_visa: yes_no_unfilled_to_checkbox_0(@intake.spouse_was_on_visa),
      primary_was_on_visa: yes_no_unfilled_to_checkbox_0(@intake.was_on_visa)
    }
    answers.merge!(demographic_info) if @intake.demographic_questions_opt_in_yes?
    answers.merge!(primary_info)
    answers.merge!(spouse_info)
    answers.merge!(dependents_info) if @dependents.present?
    answers
  end

  def primary_info
    {
      first_name: @intake.primary_first_name,
      last_name: @intake.primary_last_name,
      date_of_birth: strftime_date(@intake.primary_birth_date),
      phone_number: @intake.formatted_phone_number,
      email_address: @intake.email_address,
    }
  end

  def spouse_info
    {
      spouse_first_name: @intake.spouse_first_name,
      spouse_last_name: @intake.spouse_last_name,
      spouse_date_of_birth: strftime_date(@intake.spouse_birth_date),
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
        resident: yes_no_unfilled_to_YN(dependent.north_american_resident),
        citizen: dependent.on_visa_yes? ? "On Visa" : "",
        student: yes_no_unfilled_to_YN(dependent.was_student),
        marital_status: married_to_SM(dependent.was_married)
      }.each do |key, value|
        full_key = "#{prefix}_#{key}".to_sym
        answers[full_key] = value
      end
    end
    answers
  end

  def demographic_info
    {
      demographic_english_conversation: @intake.demographic_english_conversation,
      demographic_english_reading: @intake.demographic_english_reading,
      demographic_household_disability: @intake.demographic_disability,
      demographic_household_veteran: @intake.demographic_veteran,
      demographic_primary_race_american_indian_alaska_native: bool_checkbox_0(@intake.demographic_primary_american_indian_alaska_native),
      demographic_primary_race_asian: bool_checkbox_0(@intake.demographic_primary_asian),
      demographic_primary_race_black_african_american: bool_checkbox_0(@intake.demographic_primary_black_african_american),
      demographic_primary_race_native_hawaiian_pacific_islander: bool_checkbox_0(@intake.demographic_primary_native_hawaiian_pacific_islander),
      demographic_primary_race_white: bool_checkbox_0(@intake.demographic_primary_white),
      demographic_primary_race_prefer_not_to_answer_race: bool_checkbox_0(@intake.demographic_primary_prefer_not_to_answer_race),
      demographic_spouse_race_american_indian_alaska_native: bool_checkbox_0(@intake.demographic_spouse_american_indian_alaska_native),
      demographic_spouse_race_asian: bool_checkbox_0(@intake.demographic_spouse_asian),
      demographic_spouse_race_black_african_american: bool_checkbox_0(@intake.demographic_spouse_black_african_american),
      demographic_spouse_race_native_hawaiian_pacific_islander: bool_checkbox_0(@intake.demographic_spouse_native_hawaiian_pacific_islander),
      demographic_spouse_race_white: bool_checkbox_0(@intake.demographic_spouse_white),
      demographic_spouse_race_prefer_not_to_answer_race: bool_checkbox_0(@intake.demographic_spouse_prefer_not_to_answer_race),
      demographic_primary_ethnicity: @intake.demographic_primary_ethnicity,
      demographic_spouse_ethnicity: @intake.demographic_spouse_ethnicity,
    }
  end

  private

  def determine_direct_deposit(intake)
    return "yes" if intake.refund_payment_method_direct_deposit?
    return "no" if intake.refund_payment_method_check?

    "unfilled"
  end


  # Oddly, 0 is checked and 1 is unchecked in the 2020 f13614-c.
  def yes_no_unfilled_to_checkbox_0(value)
    value == "yes" ? 0 : nil
  end

  # Oddly, 0 is checked value in the 2020 f13614-c.
  def yes_no_unfilled_to_opposite_checkbox_0(value)
    value == "no" ? 0 : nil
  end

  # Oddly, 0 is checked value in the 2020 f13614-c.
  def bool_checkbox_0(value)
    value ? 0 : nil
  end

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
