module Ctc
  class AdvanceCtcClaimedForm < QuestionsForm
    set_attributes_for(:no_model, :advance_ctc_claimed_choice)

    def save
      return unless advance_ctc_claimed_choice == "change_amount" || advance_ctc_claimed_choice == "add_dependents"

      @intake.update(advance_ctc_entry_method: 'unfilled', advance_ctc_amount_received: nil)
    end
  end
end
