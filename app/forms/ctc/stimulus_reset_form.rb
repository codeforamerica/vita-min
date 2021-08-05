module Ctc
  class StimulusResetForm < QuestionsForm
    def save
      @intake.update(
        eip1_amount_received: nil,
        eip2_amount_received: nil,
        eip1_entry_method: "unfilled",
        eip2_entry_method: "unfilled"
      )
    end
  end
end
