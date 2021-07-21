class CtcCalculator
  PER_DEPENDENT_UNDER_SIX = 600
  PER_DEPENDENT_OVER_SIX = 250
  TOTAL_MONTHS_PAID = 12

  def self.monthly(dependents_under_six_count:, dependents_over_six_count:)
    under_six_payment = dependents_under_six_count * PER_DEPENDENT_UNDER_SIX
    over_six_payment = dependents_over_six_count * PER_DEPENDENT_OVER_SIX

    under_six_payment + over_six_payment
  end

  def self.total(dependents_under_six_count:, dependents_over_six_count:)
    monthly_payment = monthly(dependents_under_six_count: dependents_under_six_count, dependents_over_six_count: dependents_over_six_count)

    monthly_payment * TOTAL_MONTHS_PAID
  end
end
