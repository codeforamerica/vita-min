module StateFile
  class NjMedicalExpensesForm < QuestionsForm
    set_attributes_for :intake,
                       :medical_expenses

    validates_numericality_of :medical_expenses, message: I18n.t("validators.not_a_number"), if: -> { medical_expenses.present? }
    validates :medical_expenses, allow_blank: true, numericality: { greater_than_or_equal_to: 0 }
                   
    def save
      @intake.update(attributes_for(:intake))
    end
  end
end