require 'csv'

module StateFile
  module Questions
    class NySchoolDistrictController < QuestionsController
      layout "state_file/question"
      before_action :create_district_and_combined_name_mappings_from_csv, only: [:update]
      before_action :get_county_school_districts_from_csv, only: [:edit]

      private

      def get_county_school_districts_from_csv
        @school_districts = county_rows_from_csv.map do |row|
          combined_name = [row['School District'], row['Use Elementary School District']].join(" ").strip
          [combined_name, combined_name]
        end.uniq
      end

      def create_district_and_combined_name_mappings_from_csv
        @combined_district_name_mapping = Hash.new
        @district_code_mapping = Hash.new
        county_rows_from_csv.each do |row|
          combined_name = [row['School District'], row['Use Elementary School District']].join(" ").strip
          @district_code_mapping[combined_name] = row['Code Number']

          if combined_name != row['School District']
            @combined_district_name_mapping[combined_name] = row['School District']
          end
        end
      end

      def county_rows_from_csv
        csv_file_path = Rails.root.join('docs', 'ny_school_districts.csv')
        csv_content = File.read(csv_file_path)
        io = StringIO.new(csv_content)
        CSV.parse(io, headers: true).filter { |row| row["County"] == current_intake.residence_county }
      end

      def form_params
        school_district_from_params = params[:state_file_ny_school_district_form][:school_district]
        school_district_number = @district_code_mapping[school_district_from_params]
        original_name = @combined_district_name_mapping[school_district_from_params]
        if original_name.present?
          school_district = original_name
        else
          school_district = school_district_from_params
        end

        super.merge(
          school_district: school_district,
          school_district_number: school_district_number.to_i
        )
      end

      def illustration_path; end
    end
  end
end
