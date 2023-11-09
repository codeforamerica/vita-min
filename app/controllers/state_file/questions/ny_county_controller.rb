require 'csv'

module StateFile
  module Questions
    class NyCountyController < QuestionsController
      def edit
        @counties = counties_from_csv
        super
      end

      private

      def counties_from_csv
        csv_file_path = Rails.root.join('docs', 'ny_school_districts.csv')
        csv_content = File.read(csv_file_path)

        io = StringIO.new(csv_content)
        CSV.parse(io, headers: true).map do |row|
          row['County']
        end.uniq
      end

      def illustration_path; end
    end
  end
end
