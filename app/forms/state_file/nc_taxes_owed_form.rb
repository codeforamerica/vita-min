module StateFile
  class NcTaxesOwedForm < TaxesOwedForm

    with_options unless: -> { payment_or_deposit_type == "mail" || !form_submitted_before_payment_deadline? } do
      validate :withdrawal_date_validations
    end

    def withdrawal_date_validations
      five_pm_et = app_time_eastern.change(hour: 17, min: 0, sec: 0)
      if (app_time_eastern >= five_pm_et) && less_than_two_business_days_in_future?
        errors.add(:date_electronic_withdrawal, I18n.t("errors.attributes.nc_withdrawal_date.post_five_pm"))
      end
      if date_electronic_withdrawal <= app_time_eastern.to_date
        errors.add(:date_electronic_withdrawal, I18n.t("errors.attributes.nc_withdrawal_date.past"))
      end
      if date_electronic_withdrawal.saturday? || date_electronic_withdrawal.sunday?
        errors.add(:date_electronic_withdrawal, I18n.t("errors.attributes.nc_withdrawal_date.weekend"))
      end
      if Holidays.on(date_electronic_withdrawal, :us, :federalreservebanks, :observed).any?
        errors.add(:date_electronic_withdrawal, I18n.t("errors.attributes.nc_withdrawal_date.holiday"))
      end
    end

    private

    def app_time_eastern
      @form_submitted_time.in_time_zone('Eastern Time (US & Canada)')
    end

    def add_business_days(num_days)
      current_date = app_time_eastern.to_date
      while num_days.positive?
        current_date += 1.day
        # Check if the current date is a business day (Mon-Fri)
        if current_date.wday.between?(1, 5)  # wday 1-5 are Monday to Friday
          num_days -= 1.day
        end
      end
      current_date
    end

    def less_than_two_business_days_in_future?
      two_business_days_later = add_business_days(2)
      date_electronic_withdrawal <= two_business_days_later
    end
  end
end
