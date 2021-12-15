class Archived::Intake::GyrIntake2021 < Archived::Intake2021
  enum adopted_child: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :adopted_child
  enum already_applied_for_stimulus: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :already_applied_for_stimulus
  enum bought_energy_efficient_items: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :bought_energy_efficient_items
  enum bought_health_insurance: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :bought_health_insurance
  enum balance_pay_from_bank: { unfilled: 0, yes: 1, no: 2 }, _prefix: :balance_pay_from_bank
  enum claimed_by_another: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :claimed_by_another
  enum demographic_questions_opt_in: { unfilled: 0, yes: 1, no: 2 }, _prefix: :demographic_questions_opt_in
  enum demographic_english_conversation: { unfilled: 0, very_well: 1, well: 2 , not_well: 3, not_at_all: 4, prefer_not_to_answer: 5}, _prefix: :demographic_english_conversation
  enum demographic_english_reading: { unfilled: 0, very_well: 1, well: 2 , not_well: 3, not_at_all: 4, prefer_not_to_answer: 5}, _prefix: :demographic_english_reading
  enum demographic_disability: { unfilled: 0, yes: 1, no: 2, prefer_not_to_answer: 3 }, _prefix: :demographic_disability
  enum demographic_veteran: { unfilled: 0, yes: 1, no: 2, prefer_not_to_answer: 3 }, _prefix: :demographic_veteran
  enum demographic_primary_ethnicity: { unfilled: 0, hispanic_latino: 1, not_hispanic_latino: 2, prefer_not_to_answer: 3 }, _prefix: :demographic_primary_ethnicity
  enum demographic_spouse_ethnicity: { unfilled: 0, hispanic_latino: 1, not_hispanic_latino: 2, prefer_not_to_answer: 3 }, _prefix: :demographic_spouse_ethnicity
  enum divorced: { unfilled: 0, yes: 1, no: 2 }, _prefix: :divorced
  enum ever_married: { unfilled: 0, yes: 1, no: 2 }, _prefix: :ever_married
  enum ever_owned_home: { unfilled: 0, yes: 1, no: 2 }, _prefix: :ever_owned_home
  enum feeling_about_taxes: { unfilled: 0, positive: 1, neutral: 2, negative: 3 }, _prefix: :feeling_about_taxes
  enum filing_for_stimulus: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :filing_for_stimulus
  enum filing_joint: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :filing_joint
  enum had_asset_sale_income: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_asset_sale_income
  enum had_debt_forgiven: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_debt_forgiven
  enum had_dependents: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_dependents
  enum had_disability: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_disability
  enum had_disability_income: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_disability_income
  enum had_disaster_loss: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_disaster_loss
  enum had_farm_income: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_farm_income
  enum had_gambling_income: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_gambling_income
  enum had_hsa: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_hsa
  enum had_interest_income: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_interest_income
  enum had_local_tax_refund: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_local_tax_refund
  enum had_other_income: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_other_income
  enum had_rental_income: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_rental_income
  enum had_retirement_income: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_retirement_income
  enum had_self_employment_income: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_self_employment_income
  enum had_social_security_income: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_social_security_income
  enum had_social_security_or_retirement: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_social_security_or_retirement
  enum had_student_in_family: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_student_in_family
  enum had_tax_credit_disallowed: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_tax_credit_disallowed
  enum had_tips: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_tips
  enum had_unemployment_income: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_unemployment_income
  enum had_wages: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_wages
  enum income_over_limit: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :income_over_limit
  enum issued_identity_pin: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :issued_identity_pin
  enum lived_with_spouse: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :lived_with_spouse
  enum made_estimated_tax_payments: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :made_estimated_tax_payments
  enum married: { unfilled: 0, yes: 1, no: 2 }, _prefix: :married
  enum multiple_states: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :multiple_states
  enum needs_help_2016: { unfilled: 0, yes: 1, no: 2 }, _prefix: :needs_help_2016
  enum needs_help_2017: { unfilled: 0, yes: 1, no: 2 }, _prefix: :needs_help_2017
  enum needs_help_2018: { unfilled: 0, yes: 1, no: 2 }, _prefix: :needs_help_2018
  enum needs_help_2019: { unfilled: 0, yes: 1, no: 2 }, _prefix: :needs_help_2019
  enum needs_help_2020: { unfilled: 0, yes: 1, no: 2 }, _prefix: :needs_help_2020
  enum needs_help_2021: { unfilled: 0, yes: 1, no: 2 }, _prefix: :needs_help_2021
  enum no_eligibility_checks_apply: { unfilled: 0, yes: 1, no: 2 }, _prefix: :no_eligibility_checks_apply
  enum no_ssn: { unfilled: 0, yes: 1, no: 2 }, _prefix: :no_ssn
  enum paid_alimony: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :paid_alimony
  enum paid_charitable_contributions: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :paid_charitable_contributions
  enum paid_dependent_care: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :paid_dependent_care
  enum paid_local_tax: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :paid_local_tax
  enum paid_medical_expenses: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :paid_medical_expenses
  enum paid_mortgage_interest: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :paid_mortgage_interest
  enum paid_retirement_contributions: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :paid_retirement_contributions
  enum paid_school_supplies: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :paid_school_supplies
  enum paid_student_loan_interest: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :paid_student_loan_interest
  enum phone_number_can_receive_texts: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :phone_number_can_receive_texts
  enum received_alimony: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :received_alimony
  enum received_homebuyer_credit: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :received_homebuyer_credit
  enum received_irs_letter: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :received_irs_letter
  enum received_stimulus_payment: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :received_stimulus_payment
  enum reported_asset_sale_loss: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :reported_asset_sale_loss
  enum reported_self_employment_loss: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :reported_self_employment_loss
  enum satisfaction_face: { unfilled: 0, positive: 1, neutral: 2, negative: 3 }, _prefix: :satisfaction_face
  enum savings_split_refund: { unfilled: 0, yes: 1, no: 2 }, _prefix: :savings_split_refund
  enum savings_purchase_bond: { unfilled: 0, yes: 1, no: 2 }, _prefix: :savings_purchase_bond
  enum separated: { unfilled: 0, yes: 1, no: 2 }, _prefix: :separated
  enum sold_a_home: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :sold_a_home
  enum sold_assets: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :sold_assets
  enum spouse_consented_to_service: { unfilled: 0, yes: 1, no: 2 }, _prefix: :spouse_consented_to_service
  enum spouse_was_full_time_student: { unfilled: 0, yes: 1, no: 2}, _prefix: :spouse_was_full_time_student
  enum spouse_was_on_visa: { unfilled: 0, yes: 1, no: 2 }, _prefix: :spouse_was_on_visa
  enum spouse_had_disability: { unfilled: 0, yes: 1, no: 2 }, _prefix: :spouse_had_disability
  enum spouse_was_blind: { unfilled: 0, yes: 1, no: 2 }, _prefix: :spouse_was_blind
  enum spouse_issued_identity_pin: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :spouse_issued_identity_pin
  enum was_blind: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :was_blind
  enum was_full_time_student: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :was_full_time_student
  enum was_on_visa: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :was_on_visa
  enum widowed: { unfilled: 0, yes: 1, no: 2 }, _prefix: :widowed
  enum wants_to_itemize: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :wants_to_itemize

  after_save do
    if saved_change_to_completed_at?(from: nil)
      InteractionTrackingService.record_incoming_interaction(client) # client completed intake
    elsif completed_at.present?
      InteractionTrackingService.record_internal_interaction(client) # user updated completed intake
    end
  end

  def relevant_document_types
    DocumentTypes::ALL_TYPES.select do |doc_type_class|
      doc_type_class.relevant_to?(self)
    end
  end

  def relevant_intake_document_types
    DocumentNavigation::FLOW.map do |doc_type_controller|
      doc_type = doc_type_controller.document_type
      doc_type if doc_type && doc_type.relevant_to?(self)
    end.compact
  end

  def document_types_definitely_needed
    relevant_document_types.select(&:needed_if_relevant?).reject do |document_type|
      documents.where(document_type: document_type.key).present?
    end
  end

  # create a faux bank account to turn bank account data into a BankAccount object
  def bank_account
    return nil unless encrypted_bank_account_number || encrypted_bank_name || encrypted_bank_routing_number

    type = Archived::BankAccount2021.account_types.keys.include?(bank_account_type) ? bank_account_type : nil
    @bank_account ||= Archived::BankAccount2021.new(account_type: type, bank_name: bank_name, account_number: bank_account_number, routing_number: bank_routing_number)
  end

  def document_types_possibly_needed
    relevant_document_types.reject(&:needed_if_relevant?).reject do |document_type|
      document_type == DocumentTypes::Other
    end.reject do |document_type|
      documents.where(document_type: document_type.key).present?
    end
  end
end
