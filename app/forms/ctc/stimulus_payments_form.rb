module Ctc
  class StimulusPaymentsForm < QuestionsForm
    set_attributes_for(
      :no_model,
      :eip_received_choice,
    )

    def save
      tax_return = intake.default_tax_return
      case eip_received_choice
      when 'this_amount'
        benefits = Efile::BenefitsEligibility.new(tax_return: tax_return, dependents: intake.dependents)
        @intake.update(
          eip3_entry_method: 'calculated_amount',
          eip3_amount_received: benefits.eip3_amount,
        )
      when 'different_amount'
        @intake.update(
          eip3_entry_method: 'unfilled',
          eip3_amount_received: nil,
        )
      when 'no_amount'
        @intake.update(
          eip3_entry_method: 'did_not_receive',
          eip3_amount_received: 0,
        )
      end
    end
  end
end
