class EconomicImpactPaymentThreeCalculator
  INDIVIDUALS_MULTIPLIER = 1400
  DEPENDENTS_MULTIPLIER = 1400

  def self.payment_due(eligible_individuals:, eligible_dependents:)
    individuals_payment = INDIVIDUALS_MULTIPLIER * eligible_individuals
    dependents_payment = DEPENDENTS_MULTIPLIER * eligible_dependents

    individuals_payment + dependents_payment
  end
end
