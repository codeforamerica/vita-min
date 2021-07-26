module Ctc
  class StimulusPaymentsForm < QuestionsForm
    set_attributes_for :intake, :eip1_amount_received, :eip2_amount_received

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end
