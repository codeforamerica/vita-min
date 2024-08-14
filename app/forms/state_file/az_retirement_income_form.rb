module StateFile
  class AzRetirementIncomeForm < QuestionsForm
    set_attributes_for :intake,
                       :received_military_retirement_payment,
                       :received_military_retirement_payment_amount,
                       :primary_received_pension,
                       :primary_received_pension_amount,
                       :spouse_received_pension,
                       :spouse_received_pension_amount

    validates :received_military_retirement_payment_amount, presence: true, allow_blank: false, if: -> { received_military_retirement_payment == "yes" }
    validates_numericality_of :received_military_retirement_payment_amount, if: -> { received_military_retirement_payment == "yes" }
    validates_numericality_of :primary_received_pension_amount, if: -> { primary_received_pension == "yes" }
    validates_numericality_of :spouse_received_pension_amount, if: -> { spouse_received_pension == "yes" }
  end
end