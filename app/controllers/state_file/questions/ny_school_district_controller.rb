require 'csv'

module StateFile
  module Questions
    class NySchoolDistrictController < QuestionsController
      layout "state_file/question"

      def edit
        # @school_districts = county_school_districts_from_csv(current_intake.residence_county)
        # TODO: in edit, we only need to construct the options for the dropdowns
        map_county_school_districts_from_csv(current_intake.residence_county)
        super
      end

      def update
        # TODO: in update, we only need to construct the mapping for the school codes
        map_county_school_districts_from_csv(current_intake.residence_county)
        super
      end

      private

      # def county_school_districts_from_csv(county)
      def map_county_school_districts_from_csv(county)
        csv_file_path = Rails.root.join('docs', 'ny_school_districts.csv')
        csv_content = File.read(csv_file_path)

        io = StringIO.new(csv_content)

        # county_school_districts = CSV.parse(io, headers: true).filter { |row| row["County"] == county }
        # county_school_districts.map do |row|
        #   label = [row['School District'], row['Use Elementary School District']].join(" ").strip
        #   [label, row['School District']]
        # end.uniq

        @school_districts = Set.new
        @elementary_school_districts = Set.new
        # @combined_district_mapping = Hash.new
        @district_code_mapping = Hash.new

        county_school_districts = CSV.parse(io, headers: true).filter { |row| row["County"] == county }
        county_school_districts.each do |row|
          school_district = row['School District']
          elementary_school_district_with_code = row['Use Elementary School District']

          @school_districts.add([school_district, school_district])
          @district_code_mapping[school_district] = row['Code Number']

          if elementary_school_district_with_code.present?
            @elementary_school_districts.add([elementary_school_district_with_code, elementary_school_district_with_code])

            # TODO: this code will only become relevant if we have to dynamically update the elementary school dropdown to only show the districts associated with the selected district
            # if @combined_district_mapping[school_district].present?
            #   @combined_district_mapping[school_district] << elementary_school_district_with_code
            # else
            #   @combined_district_mapping[school_district] = [elementary_school_district_with_code]
            # end
          end
        end
      end

      def form_params
        elementary_school_district = params[:state_file_ny_school_district_form][:elementary_school_district]
        if elementary_school_district.present?
          school_district_number = @district_code_mapping[elementary_school_district]
        else
          school_district_number = @district_code_mapping[params[:state_file_ny_school_district_form][:school_district]]
        end
        super.merge(
          school_district_number: school_district_number.to_i
        )
      end

      def illustration_path; end
    end
  end
end
