require 'csv'

module StateFile
  module Questions
    class NySchoolDistrictController < QuestionsController
      layout "state_file/question"

      def edit
        @school_districts = county_school_districts_from_csv(params[:residence_county])
        super
      end

      private

      def county_school_districts_from_csv(county)
        csv_file_path = Rails.root.join('docs', 'ny_school_districts.csv')
        csv_content = File.read(csv_file_path)

        io = StringIO.new(csv_content)
        county_school_districts = CSV.parse(io, headers: true).filter { |row| row["County"] == county }
        county_school_districts.map do |row|
          label = [row['School District'], row['Use Elementary School District']].join(" ").strip
          value = [row['School District'], label]
          [label, row['School District']]
        end.uniq
      end

      def county_school_codes(count)
        [
          ["Bellmore-Merrick CHS Bellmore", 46]
        ]
      end

      def illustration_path; end
    end
  end
end
