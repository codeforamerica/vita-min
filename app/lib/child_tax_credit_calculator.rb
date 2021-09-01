class ChildTaxCreditCalculator
  # This is half of the total CTC due for 2021, but clients have to file in 2022 for the 2nd half
  PER_DEPENDENT_UNDER_SIX_PAYMENT = 300 * 6
  PER_DEPENDENT_SIX_AND_OVER_PAYMENT = 250 * 6

  def self.total_advance_payment(dependents_under_six_count:, dependents_six_and_over_count:)
    (dependents_under_six_count * PER_DEPENDENT_UNDER_SIX_PAYMENT) + (dependents_six_and_over_count * PER_DEPENDENT_SIX_AND_OVER_PAYMENT)
  end
end
