module Ctc
  class NonW2IncomeAmountForm < QuestionsForm
    set_attributes_for :intake, :non_w2_income_amount

    validates_presence_of :non_w2_income_amount
    validates :non_w2_income_amount, gyr_numericality: { only_integer: true }, if: :not_blank?

    def save
      @intake.update(attributes_for(:intake))
    end

    def not_blank?
      attributes_for(:intake)[:non_w2_income_amount].present?
    end
  end
end
