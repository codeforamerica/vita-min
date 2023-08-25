# frozen_string_literal: true

class SmsOptOutService
  def self.process(client:, params:)
    return false unless is_opting_out(params)

    intakes = Intake.where(client: client, sms_notification_opt_in: "yes")
    return true if intakes.empty?

    intakes.update(sms_notification_opt_in: "no")
    SystemNote::SmsOptOut.generate!(client: client, body: params["Body"])

    is_opting_out(params)
  end

  def self.is_opting_out(params)
    params["OptOutType"] == "Stop"
  end
end
