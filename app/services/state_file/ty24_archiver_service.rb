module StateFile
  class Ty24ArchiverService
    INTAKE_MAP = {
      :az => StateFileAzIntake,
      :id => StateFileIdIntake,
      :md => StateFileMdIntake,
      :nj => StateFileNjIntake,
      :nc => StateFileNcIntake,
    }.freeze

    attr_reader :state_code, :batch_size, :intake_class, :tax_year

    def initialize(state_code:, batch_size:)
      @state_code = state_code
      @intake_class = INTAKE_MAP[state_code.to_sym]
      @intake_class = INTAKE_MAP[state_code.to_sym] ||
        raise(ArgumentError, "Invalid state_code: #{state_code}. Must be one of: #{INTAKE_MAP.keys.join(', ')}")
      @tax_year = 2024
      @batch_size = batch_size
    end

    def self.archive!(state_code:, batch_size: 100)
      new(state_code: state_code, batch_size: batch_size).archive_all
    end

    def archive_all
      Rails.logger.info("*****Archiving for state: #{state_code}, tax_year: {tax_year}, batch_size: #{batch_size}*****")
      loop do
        batch = fetch_batch
        break if batch.empty?

        archived_ids = archive_batch(batch)
        Rails.logger.info("---Archived #{archived_ids.count} records for #{state_code.upcase}: [#{archived_ids.join(', ')}]---")
      end
      Rails.logger.info("*****Completed archive for state: #{state_code}*****")
    end

    def archive_all
      Rails.logger.info("*****Archiving for state: #{state_code}, tax_year: #{tax_year}, batch_size: #{batch_size}*****")

      et = Time.find_zone('America/New_York')
      start_date = et.parse('2025-01-15 00:00:00') # state_file_start_of_open_intake
      end_date = et.parse('2025-10-25 23:59:59') # state_file_end_of_in_progress_intakes

      # find state file intakes that have been accepted during the season
      accepted_intake_ids = EfileSubmissionTransition.joins(:efile_submission)
                                                     .where(efile_submissions: { data_source_type: intake_class.name })
                                                     .where(
                                                       efile_submission_transitions: {
                                                         created_at: start_date..end_date,
                                                         to_state: :accepted,
                                                         most_recent: true
                                                       }
                                                     ).pluck('efile_submissions.data_source_id')

      # remove intakes that have already been archived
      archived_emails = StateFileArchivedIntake.where(state_code: state_code, tax_year: tax_year)
                                               .pluck(:email_address)
      archived_phones = StateFileArchivedIntake.where(state_code: state_code, tax_year: tax_year)
                                               .pluck(:phone_number)
      scope = intake_class.where(id: accepted_intake_ids)
                .where.not(email_address: archived_emails, phone_number: archived_phones)

      scope.in_batches(of: batch_size) do |relation|
        batch = relation.to_a
        archived_ids = archive_batch(batch)
        Rails.logger.info("---Archived #{archived_ids.count} records for #{state_code.upcase}: [#{archived_ids.join(', ')}]---")
      end

      Rails.logger.info("*****Completed archive for state: #{state_code}*****")
    end

    private

    def archive_batch(intakes)
      intakes.each_with_object([]) do |intake, ids|
        archived_id = archive_intake(intake)
        ids << archived_id if archived_id
      end
    end

    def archive_intake(intake)
      unless intake.submission_pdf&.attached?
        Rails.logger.warn("~~~~~No submission_pdf for intake_id: #{intake.id}~~~~~")
        return
      end

      archived = StateFileArchivedIntake.new(
        state_code: state_code,
        tax_year: tax_year,
        hashed_ssn: intake.hashed_ssn,
        email_address: intake.email_address,
        phone_number: intake.phone_number,
        contact_preference: intake.contact_preference,
        mailing_street: intake.direct_file_data.mailing_street,
        mailing_apartment: intake.direct_file_data.mailing_apartment,
        mailing_city: intake.direct_file_data.mailing_city,
        mailing_state: intake.direct_file_data.mailing_state,
        mailing_zip: intake.direct_file_data.mailing_zip,
      )
      archived.save!
      archived.submission_pdf.attach(intake.submission_pdf.blob)
      intake.id
    rescue StandardError => e
      Rails.logger.warn("~~~~~Failed to archive intake_id: #{intake.id}: #{e.message}~~~~~")
      nil
    end

  end
end
