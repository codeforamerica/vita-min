module PhoneNumberHelper
  def local_phone_number(phone_number)
    phony_normalized = Phony.normalize(phone_number, cc: '1')
    Phony.format(phony_normalized, format: :national)
  end
end
