module PhoneNumberHelper
  delegate :formatted_phone_number, to: PhoneParser
end
