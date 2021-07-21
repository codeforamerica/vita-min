class EipThreeCalculator
  PER_FILER = 1400
  PER_DEPENDENT = 1400

  def self.amount(filer_count:, dependent_count:)
    filer_payment = PER_FILER * filer_count
    dependent_payment = PER_DEPENDENT * dependent_count

    filer_payment + dependent_payment
  end
end
