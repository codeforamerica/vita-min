module StateFile
  class Ty23ArchiverService
    INTAKE_MAP = {
      :az => StateFileAzIntake,
      :ny => StateFileNyIntake,
    }.freeze

    attr_reader :state_code, :batch_size, :data_source, :tax_year, :current_batch, :cutoff

    def initialize(state_code:, batch_size: 100, cutoff: '2025-01-01')
      @state_code = state_code
      @batch_size = batch_size
      @data_source = INTAKE_MAP[state_code.to_sym]
      @tax_year = 2023
      @cutoff = cutoff
      @current_batch = nil
      raise ArgumentError, "#{state_code} isn't an archiveable state. Expected one of #{INTAKE_MAP.keys.join(', ')}" unless data_source
    end

    def find_archiveables
      query_result = ActiveRecord::Base.connection.exec_query(query_archiveable_intakes)
      @current_batch = query_result.as_json
      Rails.logger.info("Found #{current_batch.count} #{data_source.name.pluralize} to archive.")
    end

    def archive_batch
      archived_ids = []
      @current_batch&.each do |batch_data|
        archived_intake = StateFileArchivedIntake.new(hashed_ssn: batch_data['hashed_ssn'])
        archived_intake.state_code = @state_code
        archived_intake.tax_year = @tax_year

        source_intake = data_source.find(batch_data['intake_id'])
        archived_intake.email_address = source_intake.email_address
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
          Rails.logger.warn("No submission pdf attached to intake #{batch_data['intake_id']}. Continuing with batch.")
        end

        archived_intake.save!
        archived_ids << batch_data['intake_id']
      rescue StandardError => e
        Rails.logger.warn("Caught exception #{e} for #{batch_data}. Continuing with batch.")
        next
      end
      Rails.logger.info("Archived #{archived_ids.count} #{data_source.name.pluralize}: [#{archived_ids.join(', ')}]")
      @current_batch = nil # reset the batch
      archived_ids
    end

    def query_archiveable_intakes
      <<~SQL
        SELECT
          id AS intake_id, hashed_ssn
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
