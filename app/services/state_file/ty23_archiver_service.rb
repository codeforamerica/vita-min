module StateFile
  class Ty23ArchiverService
    INTAKE_MAP = {
      :az => StateFileAzIntake,
      :ny => StateFileNyIntake,
    }.freeze

    attr_reader :state_code, :batch_size, :data_source, :tax_year, :current_batch, :cutoff

    def initialize(state_code:, batch_size: 100, cutoff: '2024-06-01')
      @state_code = state_code
      @batch_size = batch_size
      @data_source = INTAKE_MAP[state_code.to_sym]
      @tax_year = 2023
      @cutoff = cutoff
      @current_batch = nil
      raise ArgumentError, "#{state_code} isn't an archiveable state. Expected one of #{INTAKE_MAP.keys.join(', ')}" unless data_source
    end

    def find_archiveables
      @current_batch = ActiveRecord::Base.connection.exec_query(query_archiveable)
      Rails.logger.info("Found #{current_batch.count} #{data_source.name.pluralize} to archive.")
    end

    def archive_batch
      archived_ids = []
      @current_batch.each do |record|
        intake = data_source.find(record.id)
        archive_attributes = StateFileArchivedIntake.column_names
        archived_intake = StateFileArchivedIntake.new(intake.attributes.slice(*archive_attributes))
        # TODO: pull mailing address details off the intake; populate relevant fields on the archived intake record
        # mailing_apartment
        # mailing_city
        # mailing_state
        # mailing_street
        # mailing_zip
        if intake.submission_pdf.attached?
          pdf = intake.submission_pdf
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
        archived_ids << intake.id
      rescue StandardError => e
        Rails.logger.warn("Caught exception #{e} for record #{record}. Continuing with batch.")
        next
      end
      Rails.logger.info("Archived #{archived_ids.count} #{data_source.name.pluralize}: [#{archived_ids.join(', ')}]")
      @current_batch = nil # reset the batch
      archived_ids
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
