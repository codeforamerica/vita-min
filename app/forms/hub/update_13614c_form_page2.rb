# Intake mapping
# # # Part III - Income
# 1. job_count
# 2. had_tips
# 3. had_scholarships TODO: add field for scholarships
# 4. had_interest_income
# 5. had_local_tax_refund
# 6. received_alimony
# 7. had_self_employment_income
# 8. had_cash_check_digital_assets TODO: add field for cash/check/digital assets
# 9. had_asset_sale_income
# 10. had_disability_income
# 11. had_retirement_income
# 12. had_unemployment_income
# 13. had_social_security_income
# 14. alimony income or separate maintenance payments
# 15. had_rental_income
# 16. had_other_income

# # # Part IV - Expenses
# 1. paid_alimony,
#     has_ssn_of_alimony_recipient TODO: add field for has_ssn_of_alimony_recipient
# 2. paid_retirement_contributions
#    contributed_to_ira TODO: add field for retirement contribution type
# 3. paid_post_secondary_educational_expenses TODO: add field for secondary education expenses
# 4. paid_misc_expenses misc_expenses_medical_and_dental TODO: add field for medical and dental expenses
#    misc_expenses_taxes TODO: add field for (A) Taxes (State, Real Estate, Personal Property, Sales)
#    misc_expenses_mortgage_interest
#    misc_expenses_charitable_contributions
# 5. paid_dependent_care
# 6. paid_school_supplies
# 7. paid_self_employment_expenses TODO: add field for self employment expenses
# 8. paid_student_loan_interest

# # # Part V - Life  Events
# 1. had_hsa
# 2. had_debt_forgiven
# 3. adopted_child
# 4. had_tax_credit_disallowed, tax_credit_disallowed_year TODO: add field for had_tax_credit_disallowed year
# 5. bought_energy_efficient_items
# 6. received_homebuyer_credit
# 7. made_estimated_tax_payments (y/n), TODO: add made_estimated_tax_payments_amount
# 8. TODO: add field for had_capital_loss_carryover
# 9. bought_health_insurance

module Hub
  class Update13614cFormPage2 < Form
    include FormAttributes

    set_attributes_for :intake,
                       :had_wages,
                       :job_count,
                       :had_tips,
                       :had_interest_income,
                       :had_local_tax_refund,
                       :received_alimony,
                       :had_self_employment_income,
                       :had_asset_sale_income,
                       :had_disability_income,
                       :had_retirement_income,
                       :had_unemployment_income,
                       :had_social_security_income,
                       :had_rental_income,
                       :had_other_income,
                       :paid_alimony,
                       :paid_retirement_contributions,
                       :paid_dependent_care,
                       :paid_school_supplies,
                       :paid_student_loan_interest,
                       :had_hsa,
                       :had_debt_forgiven,
                       :adopted_child,
                       :had_tax_credit_disallowed,
                       :bought_energy_efficient_items,
                       :received_homebuyer_credit,
                       :made_estimated_tax_payments,
                       :had_scholarships,
                       :had_cash_check_digital_assets,
                       :has_ssn_of_alimony_recipient,
                       :contributed_to_ira,
                       :contributed_to_roth_ira,
                       :contributed_to_401k,
                       :contributed_to_other_retirement_account,
                       :paid_post_secondary_educational_expenses,
                       :paid_misc_expenses,
                       :misc_expenses_medical_and_dental,
                       :misc_expenses_mortgage_interest,
                       :misc_expenses_taxes,
                       :misc_expenses_charitable_contributions,
                       :paid_self_employment_expenses,
                       :tax_credit_disallowed_year,
                       :made_estimated_tax_payments_amount,
                       :had_capital_loss_carryover,
                       :bought_health_insurance

    attr_accessor :client

    def initialize(client, params = {})
      @client = client
      super(params)
    end

    def self.from_client(client)
      intake = client.intake
      attribute_keys = Attributes.new(attribute_names).to_sym
      new(client, existing_attributes(intake).slice(*attribute_keys))
    end

    def save
      return false unless valid?

      @client.intake.update(attributes_for(:intake))
      @client.touch(:last_13614c_update_at)
    end
  end
end
