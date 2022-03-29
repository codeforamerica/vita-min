module Ctc
  class AdvanceCtcForm < QuestionsForm
    set_attributes_for(
      :no_model,
      :advance_ctc_received_choice,
      )

    def save
      if advance_ctc_received_choice == 'yes_received'
        benefits = Efile::BenefitsEligibility.new(tax_return: intake.default_tax_return, dependents: intake.dependents)
        @intake.update(
          advance_ctc_entry_method: 'calculated_amount',
          advance_ctc_amount_received: benefits.ctc_amount / 2
        )
      elsif advance_ctc_received_choice == 'no_did_not_receive'
        @intake.update(
          advance_ctc_entry_method: 'did_not_receive',
          advance_ctc_amount_received: 0,
          )
      else #advance_ctc_received_choice == 'no_received_different_amount'
        @intake.update(
          advance_ctc_entry_method: 'unfilled',
          advance_ctc_amount_received: nil,
          )
      end
    end
  end
end
