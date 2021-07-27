module Ctc
  class StimulusPaymentsForm < QuestionsForm
    set_attributes_for(
      :intake,
      :eip1_amount_received,
      :eip2_amount_received,
      :eip1_entry_method,
      :eip2_entry_method
    )

    validates :eip1_entry_method, acceptance: { accept: 'calculated_amount' }
    validates :eip2_entry_method, acceptance: { accept: 'calculated_amount' }

    def save
      tax_return = intake.tax_return(2020)
      @intake.update(attributes_for(:intake).merge(
        eip1_amount_received: tax_return.expected_recovery_rebate_credit_one,
        eip2_amount_received: tax_return.expected_recovery_rebate_credit_two
      ))
    end
  end
end
