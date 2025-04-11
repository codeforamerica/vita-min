module StateFile
  class NcTaxesOwedForm < TaxesOwedForm
    set_attributes_for :intake,
                       :payment_or_deposit_type,
                       :routing_number,
                       :account_number,
                       :account_type,
                       :withdraw_amount
    set_attributes_for :confirmation, :routing_number_confirmation, :account_number_confirmation
    set_attributes_for :date,
                       :date_electronic_withdrawal_month,
                       :date_electronic_withdrawal_year,
                       :date_electronic_withdrawal_day,
                       :app_time

    validate :validate_withdrawal_date_fields

    def save
      attrs = attributes_for(:intake)
      date = form_submitted_before_payment_deadline? ? date_electronic_withdrawal : next_available_date(Time.parse(app_time))

      @intake.update(attrs.merge(date_electronic_withdrawal: date))
    end

    private

    def validate_withdrawal_date_fields
      return if payment_or_deposit_type == "mail"
      return unless form_submitted_before_payment_deadline?

      withdrawal_date_is_after_today
      withdrawal_date_is_not_on_a_weekend
      withdrawal_date_is_not_a_federal_holiday
      withdrawal_date_is_at_least_two_business_days_in_the_future_if_after_5pm
    end

    def withdrawal_date_is_after_today
      unless date_electronic_withdrawal.after?(@form_submitted_time.to_date)
        errors.add(:date_electronic_withdrawal, I18n.t("errors.attributes.nc_withdrawal_date.past"))
      end
    end

    def withdrawal_date_is_not_on_a_weekend
      if date_electronic_withdrawal.saturday? || date_electronic_withdrawal.sunday?
        errors.add(:date_electronic_withdrawal, I18n.t("errors.attributes.nc_withdrawal_date.weekend"))
      end
    end

    def withdrawal_date_is_not_a_federal_holiday
      if holiday?(date_electronic_withdrawal)
        errors.add(:date_electronic_withdrawal, I18n.t("errors.attributes.nc_withdrawal_date.holiday"))
      end
    end
  end
end
