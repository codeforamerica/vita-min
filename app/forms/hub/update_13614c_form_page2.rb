# Intake mapping
# # # Part III - Income

# 1. job_count
# 2. had_tips
# 3. ? TODO: add field for scholarships
# 4. had_interest_income
# 5. had_local_tax_refund
# 6. paid_alimony
# 7. had_self_employment_income
# 8. has_crypto_income
# 9. had_asset_sale_income
# 10. had_disability_income
# 11. had_retirement_income
# 12. had_unemployment_income
# 13. had_social_security_or_retirement OR had_social_security
# 14. had_rental_income
# 15. had_other_income

# # # Part IV - Expenses
# 1. paid_alimony, ?
# 2. paid_retirement_contributions, ?
# 3. ?
# 4. ?, ?, paid_mortgage_interest, paid_charitable_contributions
# 5. paid_dependent_care
# 6. paid_school_supplies
# 7. ?
# 8. paid_student_loan_interest

# # # Part V - Life  Events
# 1. had_hsa
# 2. had_debt_forgiven
# 3. adopted_child
# 4. had_tax_credit_disallowed
# 5. bought_energy_efficient_items
# 6. received_homebuyer_credit
# 7. made_estimated_tax_payments (y/n), made_estimated_tax_payments $$
# 8. ? #TODO: add this field for capital_loss_carryover
# 9. ? #TODO: marketplace_health_insurance

module Hub
  class Update13614cFormPage2 < ClientForm
    set_attributes_for :intake, :job_count
                       # :primary_first_name,
                       # :primary_last_name,
                       # :primary_middle_initial,
                       # :married,
                       # :separated,
                       # :widowed,
                       # :lived_with_spouse,
                       # :divorced,
                       # :divorced_year,
                       # :separated_year,
                       # :widowed_year,
                       # :claimed_by_another,
                       # :issued_identity_pin,
                       # :email_address,
                       # :phone_number,
                       # :had_disability,
                       # :was_full_time_student,
                       # :primary_birth_date,
                       # :street_address,
                       # :city,
                       # :state,
                       # :zip_code,
                       # :street_address2,
                       # :spouse_first_name,
                       # :spouse_last_name,
                       # :spouse_middle_initial,
                       # :was_blind,
                       # :spouse_was_blind,
                       # :spouse_birth_date,
                       # :spouse_had_disability,
                       # :spouse_was_full_time_student
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
      # return false unless valid?
      #
      # @client.intake.update(attributes_for(:intake).merge(dependents_attributes: formatted_dependents_attributes))
      # @client.touch(:last_13614c_update_at)
    end
  end
end
