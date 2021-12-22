module PhoneNumberHelper
  delegate :formatted_phone_number, :phone_number_link, to: PhoneParser
end
