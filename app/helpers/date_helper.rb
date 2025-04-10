module DateHelper
  def valid_primary_birth_date
    valid_text_birth_date(primary_birth_date_year, primary_birth_date_month, primary_birth_date_day, :primary_birth_date)
  end

  def valid_spouse_birth_date
    valid_text_birth_date(spouse_birth_date_year, spouse_birth_date_month, spouse_birth_date_day, :spouse_birth_date)
  end

  def valid_birth_date
    parsed_birth_date = parse_date_params(birth_date_year, birth_date_month, birth_date_day)
    unless parsed_birth_date.present?
      self.errors.add(:birth_date, I18n.t("helpers.birth_date_helper.valid_birth_date"))
      return false
    end

    if parsed_birth_date.year < 1900 || parsed_birth_date.year > Date.today.year
      self.errors.add(:birth_date, I18n.t("helpers.birth_date_helper.valid_birth_date"))
      return false
    end

    true
  end

  def valid_text_birth_date(birth_date_year, birth_date_month, birth_date_day, key = :birth_date)
    parsed_birth_date = parse_date_params(birth_date_year, birth_date_month, birth_date_day)
    unless parsed_birth_date.present?
      errors.add(key, I18n.t('errors.attributes.birth_date.blank'))
      return false
    end

    if parsed_birth_date.year < 1900 || parsed_birth_date.year > Date.today.year
      errors.add(key, I18n.t('errors.attributes.birth_date.blank'))
      return false
    end

    true
  end

  def valid_expiration_date(date_year, date_month, date_day, key = :expiration_date)
    if date_year.present? && date_year.starts_with?("19")
      errors.add(key, I18n.t('errors.attributes.expiration_date.format'))
      return false
    end
    valid_text_date(date_year, date_month, date_day, key)
  end

  def valid_text_date(date_year, date_month, date_day, key = :date)
    if date_year.present?
      unless date_year.length == 4 && (date_year.starts_with?("19") || date_year.starts_with?("20"))
        errors.add(key, I18n.t('errors.attributes.date.format'))
        return false
      end
    end

    parsed_date = parse_date_params(date_year, date_month, date_day)
    unless parsed_date.present?
      errors.add(key, I18n.t('errors.attributes.birth_date.blank'))
      return false
    end

    true
  end

  def withdrawal_date_is_at_least_two_business_days_in_the_future_if_after_5pm
    # From the ticket (FYST-1061):
    # if you submit your bank draft payment after 5:00 pm EST, the earliest draft date available will be two business days in the future
    after_5pm = after_5pm_in_nc(@form_submitted_time)
    two_business_days_away = add_business_days_to_date(@form_submitted_time.to_date, 2)
    if after_5pm && !date_electronic_withdrawal.to_date.after?(two_business_days_away)
      errors.add(:date_electronic_withdrawal, I18n.t("errors.attributes.nc_withdrawal_date.post_five_pm"))
    end
  end

  def next_available_date(current_time)
    initial_days_to_add = after_5pm_in_nc(current_time).hour >= 17 ? 2 : 1
    date = add_business_days_to_date(current_time, initial_days_to_add)
    date = add_business_days_to_date(date, 1) while holiday?(date)

    date
  end

  def holiday?(date)
    Holidays.on(date, :us, :federalreservebanks, :observed).any?
  end

  def after_5pm_in_nc(time)
    time.hour >= 17
  end

  def add_business_days_to_date(date, num_days)
    while num_days.positive?
      date += 1.day
      num_days -= 1 if date.wday.between?(1, 5) # Check if the current date is a business day (Mon-Fri)
    end
    date
  end

  def parse_date_params(year, month, day)
    date_values = [year, month, day]
    return nil if date_values.any?(&:blank?)

    begin
      Date.new(*date_values.map(&:to_i))
    rescue ArgumentError => error
      raise error unless error.to_s == "invalid date"
      nil
    end
  end
end
