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
                       :paid_local_tax,
                       :paid_mortgage_interest,
                       :paid_medical_expenses,
                       :paid_charitable_contributions,
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
