module StateFile
  class IdGroceryCreditForm < QuestionsForm
    set_attributes_for :intake,:primary_months_eligible_for_grocery_credit, :spouse_months_eligible_for_grocery_credit

    def save
      attributes_to_save = attributes_for(:intake).compact
      @intake.update(attributes_to_save)
    end
  end
end
