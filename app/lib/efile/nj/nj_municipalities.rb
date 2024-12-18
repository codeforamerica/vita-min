module Efile
  module Nj
    class NjMunicipalities
      class << self
        def county_options
          load
          @municipalities_by_county.keys.sort
        end

        def find_name_by_county_and_code(county, code)
          load
          county_rows = @municipalities_by_county[county]
          raise KeyError.new("Invalid county") unless county_rows
          municipality = county_rows.find { |muni| muni.code == code }
          raise KeyError.new("Invalid municipality code") unless municipality
          municipality.municipality_name
        end

        def municipality_select_options_for_county(county)
          load
          rows = @municipalities_by_county[county]

          raise KeyError.new("Invalid county") unless rows
          rows.map { |r| [r.municipality_name, r.code] }.sort
        end

        private

        def load
          # only load data if we don't already have it in memory
          unless @municipalities_by_county.present?
            @municipalities_by_county = {}
            csv_file_path = Rails.root.join("app/lib/efile/nj/nj_municipality_codes.csv")
            CSV.foreach(csv_file_path, headers: true) do |row|
              municipality = Municipality.new(row)
              (@municipalities_by_county[municipality.county_name] ||= []) << municipality
            end
          end
        end

        class Municipality
          attr_reader :code, :county_name, :municipality_name

          def initialize(csv_row_hash)
            @code = csv_row_hash["municipality_code"].strip
            @county_name = csv_row_hash["county_name"].strip
            @municipality_name = csv_row_hash["municipality_name"].strip
          end
        end
      end
    end
  end
end

