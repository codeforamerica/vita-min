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