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

  def withdrawal_date_deadline(state_code)
    ApplicationController.new.withdrawal_date_deadline(state_code)
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
