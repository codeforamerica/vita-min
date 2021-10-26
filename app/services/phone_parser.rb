class PhoneParser
  def self.normalize(raw_phone_number)
    return nil if raw_phone_number.nil?
    return "" if raw_phone_number == ""

    phony_normalized = Phony.normalize(raw_phone_number, cc: '1')
    if Phony.plausible?(phony_normalized)
      Phony.format(phony_normalized, format: :international, parentheses: false, spaces: '', local_spaces: '').to_s
    else
      raw_phone_number
    end
  end

  def self.formatted_phone_number(raw_phone_number)
    return nil if raw_phone_number.nil?
    return "" if raw_phone_number == ""

    phony_normalized = Phony.normalize(raw_phone_number, cc: '1')
    if Phony.plausible?(phony_normalized)
      Phony.format(phony_normalized, format: :national)
    else
      raw_phone_number
    end
  end

  def self.with_country_code(raw_phone_number)
    return nil if raw_phone_number.nil?
    return "" if raw_phone_number == ""

    phony_normalized = Phony.normalize(raw_phone_number, cc: '1')
    if Phony.plausible?(phony_normalized)
      phony_normalized
    else
      raw_phone_number
    end
  end

  def self.valid?(raw_phone_number)
    phony_normalized = Phony.normalize(raw_phone_number, cc: '1')
    Phony.plausible?(phony_normalized)
  end
end
