class PhoneParser
  def self.normalize(raw_phone_number)
    Phonelib.parse(raw_phone_number, "US").to_s
  end
end
