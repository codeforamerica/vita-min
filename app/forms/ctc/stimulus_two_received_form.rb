module Ctc
  class StimulusTwoReceivedForm < QuestionsForm
    set_attributes_for :intake, :recovery_rebate_credit_amount_2

    validates_presence_of :recovery_rebate_credit_amount_2
    validates :recovery_rebate_credit_amount_2, numericality: { only_integer: true }, if: :not_blank?

    def save
      @intake.update(attributes_for(:intake))
    end

    def not_blank?
      attributes_for(:intake)[:recovery_rebate_credit_amount_2].present?
    end
  end
end