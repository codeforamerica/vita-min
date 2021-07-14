module RrcHelper
  def calculated_or_provided_dollar_amount(intake_recovery_rebate)
    intake_recovery_rebate.present? ?
      number_to_currency(intake_recovery_rebate, precision: 0) :
      "$TBD"
  end
end