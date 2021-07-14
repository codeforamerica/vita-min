class EconomicImpactPaymentOneCalculator
  PER_INDIVIDUAL_PAYMENT = 1200
  PER_DEPENDENT_PAYMENT = 500

  def self.payment_due(filer_count:, dependent_count:)
    filers_payment = PER_INDIVIDUAL_PAYMENT * filer_count
    dependents_payment = PER_DEPENDENT_PAYMENT * dependent_count

    filers_payment + dependents_payment
  end
end
