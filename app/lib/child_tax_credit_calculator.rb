class ChildTaxCreditCalculator
  # This is half of the total CTC due for 2021, but clients have to file in 2022 for the 2nd half
  PER_DEPENDENT_UNDER_SIX_PAYMENT = 1800
  PER_DEPENDENT_SIX_AND_OVER_PAYMENT = 1500

  def self.total_advance_payment(tax_return)
    qualifying_dependents = tax_return.qualifying_dependents.filter(&:eligible_for_child_tax_credit_2020?)
    dependents_under_six, dependents_six_and_over = qualifying_dependents.partition { |qd| qd.yr_2021_age < 6 }
    (dependents_under_six.length * PER_DEPENDENT_UNDER_SIX_PAYMENT) + (dependents_six_and_over.count * PER_DEPENDENT_SIX_AND_OVER_PAYMENT)
  end
end
