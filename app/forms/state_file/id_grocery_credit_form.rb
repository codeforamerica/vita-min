module StateFile
  class IdGroceryCreditForm < QuestionsForm
    attr_accessor :dependents_attributes
    delegate :dependents, to: :intake

    set_attributes_for(
      :intake,
      :household_has_grocery_credit_ineligible_months,
      :primary_has_grocery_credit_ineligible_months,
      :spouse_has_grocery_credit_ineligible_months,
      :primary_months_ineligible_for_grocery_credit,
      :spouse_months_ineligible_for_grocery_credit
    )

    def save
      attributes_to_save = attributes_for(:intake).merge({ dependents_attributes: dependents_attributes.to_h }).compact
      @intake.update!(attributes_to_save)
    end
  end
end
