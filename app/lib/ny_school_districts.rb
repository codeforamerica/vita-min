class NySchoolDistricts
  def self.county_school_districts_labels_for_select(county)
    @school_districts ||= self.county_rows_from_csv(county).map do |row|
      combined_name = [row['School District'], row['Use Elementary School District']].join(" ").strip
      [combined_name, combined_name]
    end.uniq
  end

  def self.combined_name_to_code_number_map(county)
    @name_to_code ||= self.county_rows_from_csv(county).reduce({}) do |hash, row|
      combined_name = [row['School District'], row['Use Elementary School District']].join(" ").strip
      hash[combined_name] = row['Code Number']
      hash
    end
  end

  # includes districts where combined name is same as original
  def self.combined_name_to_original_name_map(county)
    @combined_name_to_original_name ||= self.county_rows_from_csv(county).reduce({}) do |hash, row|
      combined_name = [row['School District'], row['Use Elementary School District']].join(" ").strip
      hash[combined_name] = row['School District']
      hash
    end
  end

  def self.combined_name(intake)
    if intake.school_district_number.present? && intake.school_district.present?
      row = self.county_rows_from_csv(intake.residence_county).find do |row|
        intake.school_district == row['School District'] && intake.school_district_number == row['Code Number'].to_i
      end
      [row['School District'], row['Use Elementary School District']].join(" ").strip if row
    end
  end

  def self.county_rows_from_csv(county)
    csv_file_path = Rails.root.join('docs', 'ny_school_districts.csv')
    csv_content = File.read(csv_file_path)
    io = StringIO.new(csv_content)
    @county_rows ||= CSV.parse(io, headers: true).filter { |row| row["County"] == county }
  end
end

