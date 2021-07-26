module RrcHelper
  def calculated_or_provided_dollar_amount(intake_recovery_rebate, fallback_value = nil)
    intake_recovery_rebate.present? ?
      number_to_currency(intake_recovery_rebate, precision: 0, locale: :en) :
      fallback_value
  end
end
