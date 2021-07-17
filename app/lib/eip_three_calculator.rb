class EipThreeCalculator
  PER_FILER_PAYMENT = 1400
  PER_DEPENDENT_PAYMENT = 1400

  def self.payment_due(filer_count:, dependent_count:)
    filer_payment = PER_FILER_PAYMENT * filer_count
    dependent_payment = PER_DEPENDENT_PAYMENT * dependent_count

    filer_payment + dependent_payment
  end
end
