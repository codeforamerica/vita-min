class GetPhoneMetadataJob < ApplicationJob
  def perform(intake)
    return if intake.phone_number.blank?

    metadata = TwilioService.new(:ctc).get_metadata(phone_number: intake.phone_number)

    return if metadata.blank?

    if metadata["carrier_name"]
      intake.update(phone_carrier: metadata["carrier_name"])
    end

    if metadata["type"]
      intake.update(phone_number_type: metadata["type"])
    end
  end

  def priority
    PRIORITY_LOW
  end
end
