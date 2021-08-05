module Ctc
  class StimulusPaymentsForm < QuestionsForm
    set_attributes_for(
      :no_model,
      :eip_received_choice,
    )

    def save
      tax_return = intake.tax_return(2020)
      if eip_received_choice == 'yes_received'
        @intake.update(
          eip1_entry_method: 'calculated_amount',
          eip2_entry_method: 'calculated_amount',
          eip1_amount_received: tax_return.expected_recovery_rebate_credit_one,
          eip2_amount_received: tax_return.expected_recovery_rebate_credit_two
        )
      else
        @intake.update(
          eip1_entry_method: 'unfilled',
          eip2_entry_method: 'unfilled',
          eip1_amount_received: nil,
          eip2_amount_received: nil
        )
      end
    end
  end
end
