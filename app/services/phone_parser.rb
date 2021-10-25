class PhoneParser
  def self.normalize(raw_phone_number)
    phony_normalized = Phony.normalize(raw_phone_number, cc: '1')
    Phony.format(phony_normalized, format: :international, parentheses: false, spaces: '', local_spaces: '').to_s
  end
end
