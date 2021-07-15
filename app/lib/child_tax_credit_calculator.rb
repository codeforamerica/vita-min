class ChildTaxCreditCalculator
  PER_DEPENDENT_UNDER_SIX_PAYMENT = 600
  PER_DEPENDENT_OVER_SIX_PAYMENT = 250

  def self.monthly_payment_due(dependents_under_six_count:, dependents_over_six_count:)
    dependents_under_six_payment = dependents_under_six_count * PER_DEPENDENT_UNDER_SIX_PAYMENT
    dependents_over_six_payment = dependents_over_six_count * PER_DEPENDENT_OVER_SIX_PAYMENT

    dependents_under_six_payment + dependents_over_six_payment
  end

  def self.total_payment_due(dependents_under_six_count:, dependents_over_six_count:)
    monthly_payment_due(dependents_under_six_count: dependents_under_six_count, dependents_over_six_count: dependents_over_six_count) * 12
  end

end
