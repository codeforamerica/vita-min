class IntakePdf
  SOURCE_PDF = "app/lib/pdfs/f13614c.pdf"

  def initialize(intake)
    @intake = intake
  end

  def hash_for_pdf
    {
      had_wages: yes_no_unfilled_to_checkbox(@intake.had_wages),
      job_count: @intake.job_count,
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
  end

  def output_file
    pdf_tempfile = Tempfile.new(
      ["f13614c", ".pdf"],
      "tmp/",
    )
    PdfForms.new.fill_form(SOURCE_PDF, pdf_tempfile.path, hash_for_pdf)
    pdf_tempfile
  end

  def yes_no_unfilled_to_checkbox(value)
    value == "yes" ? "Yes" : nil
  end
end