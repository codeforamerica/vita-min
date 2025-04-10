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

    with_options unless: -> { payment_or_deposit_type == "mail" || !form_submitted_before_payment_deadline? } do
      validate :withdrawal_date_is_after_today
      validate :withdrawal_date_is_not_on_a_weekend
      validate :withdrawal_date_is_not_a_federal_holiday
      validate :withdrawal_date_is_at_least_two_business_days_in_the_future_if_after_5pm
    end

    private

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
      if Holidays.on(date_electronic_withdrawal, :us, :federalreservebanks, :observed).any?
        errors.add(:date_electronic_withdrawal, I18n.t("errors.attributes.nc_withdrawal_date.holiday"))
      end
    end

    def withdrawal_date_is_at_least_two_business_days_in_the_future_if_after_5pm
      # From the ticket (FYST-1061):
      # if you submit your bank draft payment after 5:00 pm EST, the earliest draft date available will be two business days in the future
      after_5pm = @form_submitted_time.hour >= 17
      two_business_days_away = add_business_days_to_date(@form_submitted_time.to_date, 2)
      if after_5pm && !date_electronic_withdrawal.to_date.after?(two_business_days_away)
        errors.add(:date_electronic_withdrawal, I18n.t("errors.attributes.nc_withdrawal_date.post_five_pm"))
      end
    end

    def add_business_days_to_date(date, num_days)
      while num_days.positive?
        date += 1.day
        num_days -= 1 if date.wday.between?(1, 5) # Check if the current date is a business day (Mon-Fri)
      end
      date
    end
  end
end
