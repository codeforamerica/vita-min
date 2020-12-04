module PhoneNumberHelper
  def local_phone_number(phone_number)
    Phonelib.parse(phone_number, "US").local_number
  end
end
