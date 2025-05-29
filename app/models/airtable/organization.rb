module Airtable
  class Organization < Airrecord::Table
    def self.organization_mapping
      Rails.cache.fetch('airtable_organization_mapping', expires_in: 1.hour) do
        {}.tap do |hash|
          all.each do |record|
            name = record["Organization Name"]
            next unless name.present?

            # Store both exact and normalized versions
            hash[name] = {
              primary_location: record["Primary location"],
              logo: record["Logo"]&.first&.[]("url"),
              service_models: record["Service models"] || [],
              # Add other fields you need
              original_name: name # Keep original for reference
            }
          end
        end
      end
    rescue => e
      Rails.logger.error "Airtable sync failed: #{e.message}"
      {}
    end

    def self.find_organization(query_name)
      return nil if query_name.blank?

      organization_mapping.each do |name, data|
        # Case-insensitive partial match
        if name.downcase.include?(query_name.downcase)
          return data.merge(exact_name: name)
        end
      end
      nil
    end
  end
end