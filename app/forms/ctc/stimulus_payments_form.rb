module Ctc
  class StimulusPaymentsForm < QuestionsForm
    set_attributes_for(
      :no_model,
      :eip_received_choice,
    )

    def save
      tax_return = intake.default_tax_return
      if eip_received_choice == 'yes_received'
        benefits = Efile::BenefitsEligibility.new(tax_return: tax_return, dependents: intake.dependents)
        @intake.update(
          eip1_entry_method: 'calculated_amount',
          eip2_entry_method: 'calculated_amount',
          eip1_amount_received: benefits.eip1_amount,
          eip2_amount_received: benefits.eip2_amount
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
