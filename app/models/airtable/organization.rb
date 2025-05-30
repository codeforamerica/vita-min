module Airtable
  class Organization < Airrecord::Table
    self.base_key = "app2IiqmlIPb0D6c6" # not sure if this should be in a credential file or not
    self.table_name = "tblbu4Lggkcb0hj3M"

    # made a personal access token but unsure
    Airrecord.api_key = Rails.application.credentials.dig(:airtable, :token)

    def self.primary_locations
      all.each_with_object({}) do |record, hash|
        org_name = record["Organization Name"]
        primary_location = record["Primary location"]
        hash[org_name] = primary_location if org_name.present?
      end
    end
  end
end