module StateFile
  class NjMedicalExpensesForm < QuestionsForm
    set_attributes_for :intake,
                       :medical_expenses

    validates_numericality_of :medical_expenses, only_integer: true, message: :round_to_whole_number
    validates :medical_expenses, presence: true, allow_blank: false, numericality: { greater_than_or_equal_to: 0 }
                   
    def save
      unless medical_expenses.nil?
        @intake.update(attributes_for(:intake))
      end
    end
  end
end