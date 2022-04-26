module DateHelper
  def valid_primary_birth_date
    valid_text_birth_date(primary_birth_date_year, primary_birth_date_month, primary_birth_date_day, :primary_birth_date)
  end

  def valid_spouse_birth_date
    valid_text_birth_date(spouse_birth_date_year, spouse_birth_date_month, spouse_birth_date_day, :spouse_birth_date)
  end

  def valid_birth_date
    parsed_birth_date = parse_birth_date_params(birth_date_year, birth_date_month, birth_date_day)
    unless parsed_birth_date.present?
      self.errors.add(:birth_date, I18n.t("helpers.birth_date_helper.valid_birth_date"))
      return false
    end

    if parsed_birth_date.year < 1900 || parsed_birth_date.year > Date.today.year
      self.errors.add(key, I18n.t('errors.attributes.birth_date.blank'))
      return false
    end

    true
  end

  def valid_text_birth_date(birth_date_year, birth_date_month, birth_date_day, key = :birth_date)
    parsed_birth_date = parse_birth_date_params(birth_date_year, birth_date_month, birth_date_day)
    unless parsed_birth_date.present?
      self.errors.add(key, I18n.t('errors.attributes.birth_date.blank'))
      return false
    end

    if parsed_birth_date.year < 1900 || parsed_birth_date.year > Date.today.year
      self.errors.add(key, I18n.t('errors.attributes.birth_date.blank'))
      return false
    end

    true
  end

  def valid_text_date(date_year, date_month, date_day, key = :date)
    parsed_date = parse_date_params(date_year, date_month, date_day)
    unless parsed_date.present?
      self.errors.add(key, I18n.t('errors.attributes.birth_date.blank'))
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
