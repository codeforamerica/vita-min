module BirthDateHelper
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
    true
  end

  def valid_text_birth_date(birth_date_year, birth_date_month, birth_date_day, key = :birth_date)
    parsed_birth_date = parse_birth_date_params(birth_date_year, birth_date_month, birth_date_day)
    unless parsed_birth_date.present?
      self.errors.add(key, I18n.t('errors.attributes.birth_date.blank'))
      return false
    end
    true
  end

  def parse_birth_date_params(year, month, day)
    birth_date_values = [year, month, day]
    return nil if birth_date_values.any?(&:blank?)

    begin
      Date.new(*birth_date_values.map(&:to_i))
    rescue ArgumentError => error
      raise error unless error.to_s == "invalid date"
      nil
    end
  end
end
