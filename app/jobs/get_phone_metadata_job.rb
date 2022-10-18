class GetPhoneMetadataJob < ApplicationJob
  queue_as :default

  def perform(intake)
    return if intake.phone_number.blank?

    metadata = TwilioService.get_metadata(phone_number: intake.phone_number)

    return if metadata.blank?

    if metadata["carrier_name"]
      intake.update(phone_carrier: metadata["carrier_name"])
    end

    if metadata["type"]
      intake.update(phone_number_type: metadata["type"])
    end
  end
end
