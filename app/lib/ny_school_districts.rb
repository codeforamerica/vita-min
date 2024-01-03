class NySchoolDistricts

  def self.county_labels_for_select
    self.all_county_rows_from_csv.map do |county_name, _county_rows|
      county_name
    end.uniq
  end

  def self.county_school_districts_labels_for_select(county)
    self.county_rows_from_csv(county).map do |row|
      combined_name = [row['School District'], row['Use Elementary School District']].join(" ").strip
      [combined_name, combined_name]
    end.uniq
  end

  def self.combined_name_to_code_number_map(county)
    self.county_rows_from_csv(county).each_with_object({}) do |row, hash|
      combined_name = [row['School District'], row['Use Elementary School District']].join(" ").strip
      hash[combined_name] = row['Code Number']
    end
  end

  # includes districts where combined name is same as original
  def self.combined_name_to_original_name_map(county)
    self.county_rows_from_csv(county).each_with_object({}) do |row, hash|
      combined_name = [row['School District'], row['Use Elementary School District']].join(" ").strip
      hash[combined_name] = row['School District']
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
    self.all_county_rows_from_csv[county]
  end

  def self.all_county_rows_from_csv
    @county_rows ||=
      begin
        csv_file_path = Rails.root.join("app/lib/efile/ny/school_districts.csv")
        CSV.read(csv_file_path, headers: true).each_with_object({}) do |row, hash|
          hash[row["County"].strip] ||= []
          hash[row["County"].strip] << row
        end
      end

    @county_rows
  end
end

