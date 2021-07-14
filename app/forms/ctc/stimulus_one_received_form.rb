module Ctc
  class StimulusOneReceivedForm < QuestionsForm
    set_attributes_for :intake, :recovery_rebate_credit_amount_1

    validates_presence_of :recovery_rebate_credit_amount_1
    validates :recovery_rebate_credit_amount_1, numericality: { only_integer: true }, if: :not_blank?

    def save
      @intake.update(attributes_for(:intake))
    end

    def not_blank?
      attributes_for(:intake)[:recovery_rebate_credit_amount_1].present?
    end
  end
end