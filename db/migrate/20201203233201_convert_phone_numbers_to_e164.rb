class ConvertPhoneNumbersToE164 < ActiveRecord::Migration[6.0]
  def up
    Intake.all.find_each do |intake|
      intake.update(
        phone_number: PhoneParser.normalize(intake.phone_number),
        sms_phone_number: PhoneParser.normalize(intake.sms_phone_number),
      )
    end
    IncomingTextMessage.all.find_each do |message|
      message.update(from_phone_number: PhoneParser.normalize(message.from_phone_number))
    end
    OutgoingTextMessage.all.find_each do |message|
      message.update(to_phone_number: PhoneParser.normalize(message.to_phone_number))
    end
    Signup.all.find_each do |signup|
      signup.update(phone_number: PhoneParser.normalize(signup.phone_number))
    end
  end

  def down
    # we can't reverse this and we think it's harmless
  end

  class Intake < ActiveRecord::Base; end
  class IncomingTextMessage < ActiveRecord::Base; end
  class OutgoingTextMessage < ActiveRecord::Base; end
  class Signup < ActiveRecord::Base; end
end
