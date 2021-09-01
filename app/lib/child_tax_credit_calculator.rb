class ChildTaxCreditCalculator
  PER_DEPENDENT_UNDER_SIX_PAYMENT = 300
  PER_DEPENDENT_SIX_AND_OVER_PAYMENT = 250

  def self.monthly_payment_due(dependents)
    dependents_under_six_count = dependents.count { |dependent| dependent.age_at_end_of_year(2021) < 6 }
    dependents_six_and_over_count = dependents.count - dependents_under_six_count
    dependents_under_six_payment = dependents_under_six_count * PER_DEPENDENT_UNDER_SIX_PAYMENT
    dependents_six_and_over_payment = dependents_six_and_over_count * PER_DEPENDENT_SIX_AND_OVER_PAYMENT

    dependents_under_six_payment + dependents_six_and_over_payment
  end

  # This is half of the total CTC due for 2021, but clients have to file in 2022 for the 2nd half
  def self.total_advance_payment_2021(dependents)
    monthly_payment_due(dependents) * 6
  end
end
