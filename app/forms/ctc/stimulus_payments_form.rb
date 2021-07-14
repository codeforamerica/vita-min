module Ctc
  class StimulusPaymentsForm < QuestionsForm
    set_attributes_for :intake, :recovery_rebate_credit_amount_1, :recovery_rebate_credit_amount_2

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end