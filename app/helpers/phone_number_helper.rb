module PhoneNumberHelper
  def local_phone_number(phone_number)
    unless phone_number[0] == "1" || phone_number[0..1] == "+1"
      phone_number = "1#{phone_number}"
    end
    Phonelib.parse(phone_number).local_number
  end
end
