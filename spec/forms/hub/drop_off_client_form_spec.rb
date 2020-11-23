require "rails_helper"

RSpec.describe Hub::DropOffClientForm do
  it "accepts the required parameters and creates a client etc" do
    form = Hub::DropOffClientForm.new(
      preferred_name: "Jean Parmesan",
      first_name: "Jean",
      last_name: "Parmesan",
      email: "jean@example.com",
      phone_number: "+14155551212",
      street_address: "123 Main St",
      city: "Anytown",
      state: "CA",
      zip_code: "94612",
      sms_notification_opt_in: "yes",
      email_notification_opt_in: "yes",
      tax_year_2019: "yes",
      tax_year_2018: "no",
      pickup_method: "E-Signature",
      state_for_state_return: "OR")

  end
end
