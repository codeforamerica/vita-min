module BirthDateHelper
  def valid_birth_date
    parsed_birth_date = parse_birth_date_params(birth_date_year, birth_date_month, birth_date_day)
    unless parsed_birth_date.present?
      self.errors.add(:birth_date, "Please select a valid date")
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