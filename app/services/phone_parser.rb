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
end
