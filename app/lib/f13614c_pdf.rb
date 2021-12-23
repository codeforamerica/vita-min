class F13614cPdf
  include PdfHelper

  def source_pdf_name
    "f13614c-TY2021"
  end

  def document_type
    DocumentTypes::Form13614C
  end

  def output_filename
    "F13614-C"
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
      never_married: yes_no_unfilled_to_opposite_checkbox(@intake.ever_married),
      married: yes_no_unfilled_to_checkbox(@intake.married),
      divorced: yes_no_unfilled_to_checkbox(@intake.divorced),
      widowed: yes_no_unfilled_to_checkbox(@intake.widowed),
      legally_separated: yes_no_unfilled_to_checkbox(@intake.separated),
      lived_with_spouse: @intake.lived_with_spouse,
      married_during_tax_year: nil,
      widowed_date: @intake.widowed_year,
      divorced_date: @intake.divorced_year,
      separated_date: @intake.separated_year,
      issued_pin: collective_yes_no_unsure(@intake.issued_identity_pin, @intake.spouse_issued_identity_pin),
      email_address: @intake.email_address,

      had_wages: @intake.had_wages,
      job_count: @intake.job_count.to_s,
      had_tips: @intake.had_tips,
      had_scholarships: nil,
      had_interest_income: @intake.had_interest_income,
      had_local_tax_income: @intake.had_local_tax_refund,
      received_alimony: @intake.received_alimony,
      had_self_employment_income: @intake.had_self_employment_income,
      had_unreported_income: nil,
      had_asset_sale_income_loss: collective_yes_no_unsure(@intake.had_asset_sale_income, @intake.reported_asset_sale_loss, @intake.sold_a_home),
      had_disability_income: @intake.had_disability_income,
      had_retirement_income: @intake.had_retirement_income,
      had_unemployment_income: @intake.had_unemployment_income,
      had_social_security_income: @intake.had_social_security_income,
      had_rental_income: @intake.had_rental_income,
      had_other_income: collective_yes_no_unsure(@intake.had_other_income, @intake.had_gambling_income),
      other_income_types: @intake.other_income_types,

      paid_alimony: @intake.paid_alimony,
      have_alimony_recipient_ssn: nil,

      paid_post_secondary_expenses: @intake.had_student_in_family,

      paid_retirement_contributions: @intake.paid_retirement_contributions,
      paid_into_traditional_ira: yes_no_unfilled_to_checkbox(nil),
      paid_into_401k: yes_no_unfilled_to_checkbox(nil),
      paid_into_other_retirement_account: yes_no_unfilled_to_checkbox(nil),
      paid_into_roth_ira: yes_no_unfilled_to_checkbox(nil),


      had_misc_expenses: collective_yes_no_unsure(@intake.paid_local_tax, @intake.paid_mortgage_interest, @intake.paid_medical_expenses, @intake.paid_charitable_contributions),
      paid_local_tax: yes_no_unfilled_to_checkbox(@intake.paid_local_tax),
      paid_mortgage_interest: yes_no_unfilled_to_checkbox(@intake.paid_mortgage_interest),
      paid_medical_expenses: yes_no_unfilled_to_checkbox(@intake.paid_medical_expenses),
      paid_charitable_contributions: yes_no_unfilled_to_checkbox(@intake.paid_charitable_contributions),
      paid_dependent_care: @intake.paid_dependent_care,
      paid_school_supplies: @intake.paid_school_supplies,
      paid_self_employment_expenses: nil,
      paid_student_loan_interest: @intake.paid_student_loan_interest,

      had_hsa: @intake.had_hsa,
      had_debt_forgiven: @intake.had_debt_forgiven,
      adopted_child: @intake.adopted_child,
      had_tax_credit_disallowed: @intake.had_tax_credit_disallowed,
      bought_energy_efficient_items: @intake.bought_energy_efficient_items || "unfilled", # no default in db
      received_homebuyer_credit: @intake.received_homebuyer_credit,
      made_estimated_tax_payments: @intake.made_estimated_tax_payments,
      filed_capital_loss_carryover: nil,
      bought_health_insurance: @intake.bought_health_insurance,
      received_stimulus_payment: @intake.received_stimulus_payment,
      received_advance_ctc_payment: @intake.received_advance_ctc_payment,

      ## add the amounts
      eip1_amount_received: @intake.eip1_amount_received,
      eip2_amount_received: @intake.eip2_amount_received,
      eip3_amount_received: @intake.eip3_amount_received,
      advance_ctc_amount_received: @intake.advance_ctc_amount_received,

      # Additional Information Section
      other_written_communication_language: @intake.preferred_written_language.present? ? "yes" : "no",
      preferred_written_language: @intake.preferred_written_language,
      direct_deposit: determine_direct_deposit(@intake),
      savings_purchase_bond: @intake.savings_purchase_bond,
      savings_split_refund: @intake.savings_split_refund,
      balance_due_transfer: @intake.balance_pay_from_bank,
      had_disaster_loss: @intake.had_disaster_loss,
      received_irs_letter: @intake.received_irs_letter,

      additional_comments: "#{@intake.additional_info} #{@intake.final_info}",
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
      middle_initial: nil,
      last_name: @intake.primary_last_name,
      date_of_birth: strftime_date(@intake.primary_birth_date),
      phone_number: @intake.formatted_phone_number,
      job_title: nil,
      is_citizen: nil,
      is_disabled: @intake.had_disability,
      is_student: @intake.was_full_time_student,
      is_blind: @intake.was_blind,
      is_on_visa: yes_no_unfilled_to_checkbox(@intake.was_on_visa),
    }
  end

  def spouse_info
    {
      spouse_first_name: @intake.spouse_first_name,
      spouse_middle_initial: nil,
      spouse_last_name: @intake.spouse_last_name,
      spouse_date_of_birth: strftime_date(@intake.spouse_birth_date),
      spouse_job_title: nil,
      spouse_is_blind: @intake.spouse_was_blind,
      spouse_is_disabled: @intake.spouse_had_disability,
      spouse_is_citizen: nil,
      spouse_is_student: @intake.spouse_was_full_time_student,
      spouse_is_on_visa: yes_no_unfilled_to_checkbox(@intake.spouse_was_on_visa),
    }
  end

  def dependents_info
    answers = {}
    @dependents.first(3).each_with_index do |dependent, index|
      prefix = "dependent_#{index}"
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
      demographic_primary_race_american_indian_alaska_native: bool_checkbox(@intake.demographic_primary_american_indian_alaska_native),
      demographic_primary_race_asian: bool_checkbox(@intake.demographic_primary_asian),
      demographic_primary_race_black_african_american: bool_checkbox(@intake.demographic_primary_black_african_american),
      demographic_primary_race_native_hawaiian_pacific_islander: bool_checkbox(@intake.demographic_primary_native_hawaiian_pacific_islander),
      demographic_primary_race_white: bool_checkbox(@intake.demographic_primary_white),
      demographic_primary_race_prefer_not_to_answer_race: bool_checkbox(@intake.demographic_primary_prefer_not_to_answer_race),
      demographic_spouse_race_american_indian_alaska_native: bool_checkbox(@intake.demographic_spouse_american_indian_alaska_native),
      demographic_spouse_race_asian: bool_checkbox(@intake.demographic_spouse_asian),
      demographic_spouse_race_black_african_american: bool_checkbox(@intake.demographic_spouse_black_african_american),
      demographic_spouse_race_native_hawaiian_pacific_islander: bool_checkbox(@intake.demographic_spouse_native_hawaiian_pacific_islander),
      demographic_spouse_race_white: bool_checkbox(@intake.demographic_spouse_white),
      demographic_spouse_race_prefer_not_to_answer_race: bool_checkbox(@intake.demographic_spouse_prefer_not_to_answer_race),
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
