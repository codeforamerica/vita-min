require 'csv'

module StateFile
  class NySchoolDistrictForm < QuestionsForm
    set_attributes_for :intake,
                       :school_district,
                       :school_district_number

    validates :school_district, presence: true
    validates :school_district_number, presence: true

    def save
      @intake.update(attributes_for(:intake))
    end

    def self.existing_attributes(intake)
      if intake.school_district_number.present? && intake.school_district.present?
        csv_file_path = Rails.root.join('docs', 'ny_school_districts.csv')
        csv_content = File.read(csv_file_path)
        io = StringIO.new(csv_content)
        county_rows_from_csv = CSV.parse(io, headers: true).filter { |row| row["County"] == intake.residence_county }
        name_and_code_to_combined_name = Hash.new
        county_rows_from_csv.each do |row|
          name_and_code = [row['School District'], row['Code Number'].to_i].join
          combined_name = [row['School District'], row['Use Elementary School District']].join(" ").strip
          name_and_code_to_combined_name[name_and_code] = combined_name
        end

        name_and_code = [intake.school_district, intake.school_district_number].join
        label = name_and_code_to_combined_name[name_and_code] || intake.school_district
        super.merge(school_district: label)
      else
        super
      end
    end
  end
end