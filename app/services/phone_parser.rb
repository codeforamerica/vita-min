class PhoneParser
  def self.normalize(raw_phone_number)
    valid, normalized = self.normalize_or_error(raw_phone_number)
    valid ? Phony.format(normalized, format: :international, parentheses: false, spaces: '', local_spaces: '').to_s : raw_phone_number
  end

  def self.formatted_phone_number(raw_phone_number)
    valid, normalized = self.normalize_or_error(raw_phone_number)
    valid ? Phony.format(normalized, format: :national) : raw_phone_number
  end

  def self.phone_number_link(raw_phone_number)
    valid, normalized = self.normalize_or_error(raw_phone_number)
    valid ? "tel:+#{normalized}" : "tel:"
  end

  private

  def self.normalize_or_error(raw_phone_number)
    return [false, nil] if raw_phone_number.nil?
    return [false, ""] if raw_phone_number == ""

    phony_normalized = Phony.normalize(raw_phone_number, cc: '1')
    if Phony.plausible?(phony_normalized)
      [true, phony_normalized]
    else
      [false, raw_phone_number]
    end
  end
end
