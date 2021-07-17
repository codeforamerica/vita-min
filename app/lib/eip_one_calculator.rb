class EipOneCalculator
  PER_FILER_PAYMENT = 1200
  PER_DEPENDENT_PAYMENT = 500

  def self.payment_due(filer_count:, dependent_count:)
    filer_payment = PER_FILER_PAYMENT * filer_count
    dependent_payment = PER_DEPENDENT_PAYMENT * dependent_count

    filer_payment + dependent_payment
  end
end
