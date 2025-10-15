module Airtable
  class Organization < Airrecord::Table
    self.base_key = Rails.application.credentials.dig(:airtable, :base_key)
    self.table_name = Rails.application.credentials.dig(:airtable, :table_name)

    Airrecord.api_key = Rails.application.credentials.dig(:airtable, :token)

    def self.language_offerings
      all.each_with_object({}) do |record, hash|
        org_name = record["Organization Name"]
        languages = record["Language offerings"]
        hash[org_name] = parse_languages(languages) if org_name.present?
      end
    end

    private

    def self.parse_languages(languages_field)
      return [] if languages_field.blank?
      if languages_field.is_a?(Array)
        languages_field
      elsif languages_field.is_a?(String)
        languages_field.split(',').map(&:strip)
      else
        []
      end
    end
  end
end