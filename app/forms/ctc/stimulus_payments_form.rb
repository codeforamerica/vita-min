module Ctc
  class StimulusPaymentsForm < QuestionsForm
    set_attributes_for(
      :intake,
      :eip1_amount_received,
      :eip2_amount_received,
      :eip1_entry_method,
      :eip2_entry_method
    )

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end
