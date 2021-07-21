class EipTwoCalculator
  PER_FILER = 600
  PER_DEPENDENT = 600

  def self.amount(filer_count:, dependent_count:)
    filer_payment = PER_FILER * filer_count
    dependent_payment = PER_DEPENDENT * dependent_count

    filer_payment + dependent_payment
  end
end
