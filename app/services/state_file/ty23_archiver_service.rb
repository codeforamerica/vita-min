module StateFile
  class Ty23ArchiverService
    INTAKE_MAP = {
      'az' => StateFileAzIntake,
      'ny' => StateFileNyIntake,
    }.freeze

    attr_reader :state_code, :batch_size, :data_source, :tax_year, :current_batch, :cutoff

    def initialize(state_code:, batch_size: 100, cutoff: '2024-06-01')
      @state_code = state_code
      @batch_size = batch_size
      @data_source = INTAKE_MAP[state_code]
      @tax_year = 2023
      @cutoff = cutoff
      @current_batch = nil
      raise ArgumentError, "#{state_code} isn't an archivable state. Expected one of #{INTAKE_MAP.keys.join(', ')}" unless data_source
    end

    def find_archiveables
      @current_batch = ActiveRecord::Base.connection.exec_query(query_archiveable)
      Rails.logger.info("Found #{current_batch.count} #{data_source} intakes to archive.")
    end

    def archive_batch
      archived_ids = []
      current_batch.each do |record|
        archive = StateFileArchivedIntake.new(record.without('source_intake_id'))
        archive.submission_pdf.attach(data_source.find(record['source_intake_id']).submission_pdf.blob)
        archive.save!
        archived_ids << record['source_intake_id']
      rescue StandardError => e
        Rails.logger.warn("Caught exception #{e} for record #{record}. Continuing with batch")
        next
      end
      Rails.logger.info("Archived #{archived_ids.count} #{data_source} intakes: [#{archived_ids.join(', ')}]")
      @current_batch = nil # reset the batch
    end

    def query_archiveable
      <<~SQL
        SELECT
          #{tax_year} AS tax_year, '#{state_code}' AS state_code,
          email_address, hashed_ssn, id AS source_intake_id
          FROM
          #{data_source.table_name}
        WHERE id IN (
          SELECT
            efs.data_source_id
          FROM
            efile_submission_transitions est
            LEFT JOIN EFILE_SUBMISSIONS efs ON efs.ID = est.efile_submission_id
          WHERE
            est.most_recent = TRUE
            AND est.to_state = 'accepted'
            AND est.created_at < '#{cutoff}'
            AND efs.data_source_type = '#{data_source}'
          ORDER BY
            EFS.data_source_id ASC
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
