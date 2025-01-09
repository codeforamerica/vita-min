module StateFile
  class Ty23ArchiverService
    INTAKE_MAP = {
      :az => StateFileAzIntake,
      :ny => StateFileNyIntake,
    }.freeze

    attr_reader :state_code, :batch_size, :data_source, :tax_year, :current_batch_ids, :cutoff

    def initialize(state_code:, batch_size: 100, cutoff: '2025-01-01')
      @state_code = state_code
      @batch_size = batch_size
      @data_source = INTAKE_MAP[state_code.to_sym]
      @tax_year = 2023
      @cutoff = cutoff
      @current_batch_ids = nil
      raise ArgumentError, "#{state_code} isn't an archiveable state. Expected one of #{INTAKE_MAP.keys.join(', ')}" unless data_source
    end

    def find_archiveables
      query_result = ActiveRecord::Base.connection.exec_query(query_archiveable_intake_ids)
      @current_batch_ids = query_result.map { |record| record['id'] } if query_result
      Rails.logger.info("Found #{current_batch_ids.count} #{data_source.name.pluralize} to archive.")
    end

    def archive_batch
      archived_ids = []
      @current_batch_ids&.each do |intake_id|
        source_intake = data_source.find(intake_id)
        archive_attributes = StateFileArchivedIntake.column_names
        archived_intake = StateFileArchivedIntake.new(source_intake.attributes.slice(*archive_attributes))
        archived_intake.mailing_street = source_intake.direct_file_data.mailing_street
        archived_intake.mailing_apartment = source_intake.direct_file_data.mailing_apartment
        archived_intake.mailing_city = source_intake.direct_file_data.mailing_city
        archived_intake.mailing_state = source_intake.direct_file_data.mailing_state
        archived_intake.mailing_zip = source_intake.direct_file_data.mailing_zip
        if source_intake.submission_pdf.attached?
          pdf = source_intake.submission_pdf
          archived_intake.submission_pdf.attach(
            io: StringIO.new(pdf.download),
            filename: pdf.filename.to_s,
            content_type: pdf.content_type,
          )
        else
          Rails.logger.error("No submission pdf attached for record #{record}. Continuing with batch.")
        end
        archived_intake.state_code = @state_code
        archived_intake.tax_year = @tax_year
        archived_intake.save!
        archived_ids << intake_id
      rescue StandardError => e
        Rails.logger.warn("Caught exception #{e} for record #{record}. Continuing with batch.")
        next
      end
      Rails.logger.info("Archived #{archived_ids.count} #{data_source.name.pluralize}: [#{archived_ids.join(', ')}]")
      @current_batch_ids = nil # reset the batch
      archived_ids
    end

    def query_archiveable_intake_ids
      <<~SQL
        SELECT
          id
        FROM
          #{data_source.table_name}
        WHERE id IN (
          SELECT
            efs.data_source_id
          FROM
            efile_submission_transitions est
            LEFT JOIN efile_submissions efs ON efs.ID = est.efile_submission_id
          WHERE
            est.most_recent = TRUE
            AND est.to_state = 'accepted'
            AND est.created_at < '#{cutoff}'
            AND efs.data_source_type = '#{data_source}'
          ORDER BY
            efs.data_source_id ASC
        )
        AND hashed_ssn NOT IN (
          SELECT hashed_ssn
          FROM state_file_archived_intakes
          WHERE state_code = '#{state_code}' and tax_year = #{tax_year}
        )
        LIMIT #{batch_size}
      SQL
    end
  end
end
