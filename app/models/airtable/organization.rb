module Airtable
  class Organization < Airrecord::Table
    self.base_key = EnvironmentCredentials['AIRTABLE_BASE_KEY']
    self.table_name = EnvironmentCredentials['AIRTABLE_TABLE_NAME']

    Airrecord.api_key = EnvironmentCredentials['AIRTABLE_TOKEN']

    def self.language_offerings
      all.each_with_object({}) do |record, hash|
        org_name = record["Organization Name"]
        languages = record["Language offerings"]
        hash[org_name] = parse_languages(languages) if org_name.present?
      end
    end

    def self.expanded_scope_offerings
      all.each_with_object({}) do |record, hash|
        org_name = record["Organization Name"]
        offerings = record["Expanded scope offerings"]
        hash[org_name] = parse_multi_select(offerings) if org_name.present?
      end
    end

    def self.parse_languages(languages_field)
      return [] if languages_field.blank?

      Array(languages_field).flatten.map(&:strip).reject(&:blank?)
    end

    def self.parse_multi_select(field)
      return [] if field.blank?

      Array(field).flatten.map(&:strip).reject(&:blank?)
    end

  end
end
