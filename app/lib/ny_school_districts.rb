class NySchoolDistricts
  class << self
    def county_labels
      load
      @districts_by_county_label.keys.sort
    end

    def district_select_options_for_county(county)
      load
      rows = @districts_by_county_label[county]

      raise KeyError.new("Invalid county") unless rows

      rows.map { |r| [r.combined_name, r.id] }.sort
    end

    def find_by_id(id)
      load
      @districts_by_id[id]
    end

    private

    def load
      # only load data if we don't already have it in memory
      unless @districts_by_id.present?
        @districts_by_id = {}
        @districts_by_county_label = {}
        csv_file_path = Rails.root.join("app/lib/state_file/ny/efile/school_districts.csv")
        CSV.foreach(csv_file_path, headers: true) do |row|
          district = SchoolDistrict.new(row)
          @districts_by_id[district.id] = district
          county_districts = @districts_by_county_label.fetch(district.county_label, [])
          county_districts << district
          @districts_by_county_label[district.county_label] = county_districts
        end
      end
    end

    class SchoolDistrict
      attr_reader :id, :county_name, :county_label, :district_name, :use_elementary_school_district, :code

      def initialize(csv_row_hash)
        @id = csv_row_hash["id"].to_i
        @county_name = csv_row_hash["county_name"].strip
        @county_label = csv_row_hash["county_label"].strip
        @district_name = csv_row_hash["district_name"].strip
        @use_elementary_school_district = csv_row_hash["use_elementary_school_district"]&.strip
        @code = csv_row_hash["code"].to_i
      end

      def combined_name
        district_name + (use_elementary_school_district.present? ? " #{use_elementary_school_district}" : "")
      end

      def county_code
        county_name.upcase.gsub(/[^A-Z]/i, '')[0..3]
      end
    end
  end
end

