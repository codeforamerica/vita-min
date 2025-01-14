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
      @current_batch = active_record_query
      Rails.logger.info("Found #{current_batch.count} #{data_source.name.pluralize} to archive: #{current_batch}")
    end

    def archive_batch
      archived_ids = []
      current_batch&.each do |source_intake|
        archived_intake = StateFileArchivedIntake.new
        archived_intake.state_code = state_code
        archived_intake.tax_year = tax_year

        archived_intake.hashed_ssn = source_intake.hashed_ssn
        archived_intake.email_address = source_intake.email_address
        archived_intake.mailing_street = source_intake.direct_file_data.mailing_street
        archived_intake.mailing_apartment = source_intake.direct_file_data.mailing_apartment
        archived_intake.mailing_city = source_intake.direct_file_data.mailing_city
        archived_intake.mailing_state = source_intake.direct_file_data.mailing_state
        archived_intake.mailing_zip = source_intake.direct_file_data.mailing_zip

        if source_intake.submission_pdf.attached?
          archived_intake.submission_pdf.attach(source_intake.submission_pdf.blob)
        else
          Rails.logger.warn("No submission pdf attached to intake #{source_intake.id}. Continuing with batch.")
        end

        archived_intake.save!
        archived_ids << source_intake.id
      rescue StandardError => e
        Rails.logger.warn("Caught exception #{e} for #{source_intake.id}. Continuing with batch.")
        next
      end
      Rails.logger.info("Archived #{archived_ids.count} #{data_source.name.pluralize}: [#{archived_ids.join(', ')}]")
      @current_batch = nil # reset the batch
      archived_ids
    end

    def active_record_query
      archiveable_intakes = data_source
                           .where(id:
                                    EfileSubmissionTransition
                                      .joins(:efile_submission)
                                      .where(
                                        to_state: :accepted,
                                        most_recent: true,
                                        created_at: ..Date.parse(cutoff),
                                        :efile_submission => { :data_source_type => data_source.name }
                                      ).pluck(
                                      :"efile_submission.data_source_id"
                                    )
                           ).where('email_address is not null')

      # do not archive multiple intakes with the same email address
      archived_emails = StateFileArchivedIntake.where(state_code: state_code, tax_year: tax_year).pluck(:email_address)
      unarchived_archiveable_intakes = archiveable_intakes.where.not(email_address: archived_emails)

      # There are some 2023 NY accepted intakes with duplicate hashed SSNs, and for these we will only archive the last one
      unarchived_archiveable_intakes.group_by(&:email_address).map do |_, accepted_intakes_with_same_email_address|
        accepted_intakes_with_same_email_address.max_by(&:created_at)
      end.first(batch_size)
    end
  end
end
