# frozen_string_literal: true

class SmsOptOutService
  def self.process(client, incoming_sms_params)
    return false unless is_opting_out(incoming_sms_params)

    intakes = Intake.where(client: client, sms_notification_opt_in: "yes")
    return true unless intakes.empty?

    intakes.update(sms_notification_opt_in: "no")
    SystemNote::SmsOptOut.generate!(client: client)

    is_opting_out(incoming_sms_params)
  end

  def self.is_opting_out(incoming_sms_params)
    puts incoming_sms_params["OptOutType"]
    incoming_sms_params["OptOutType"] == "Stop"
  end
end
