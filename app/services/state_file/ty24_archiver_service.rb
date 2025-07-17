module StateFile
  class Ty24ArchiverService
    STATE_INTAKES = {
      :az => StateFileAzIntake,
      :id => StateFileIdIntake,
      :md => StateFileMdIntake,
      :nj => StateFileNjIntake,
      :nc => StateFileNcIntake,
    }.freeze

    def self.archive!(state_code:, batch_size: 100, cutoff_date:)
      new(state_code: state_code, batch_size: batch_size, cutoff_date: cutoff_date).archive_all
    end

    attr_reader :state_code, :intake_class, :tax_year, :cutoff_date, :batch_size

    def initialize(state_code:, batch_size:, cutoff_date:)
      @state_code = state_code
      @intake_class = STATE_INTAKES[state_code.to_sym]
      @intake_class = STATE_INTAKES[@state_code] ||
        raise(ArgumentError, "Invalid state_code: #{@state_code}. Must be one of: #{STATE_INTAKES.keys.join(', ')}")
      @tax_year = 2024
      @batch_size = batch_size
      @cutoff_date = Date.parse(cutoff_date)
    end

    def archive_all
      Rails.logger.info("*****Starting archive for state=#{state_code}, tax_year=#{tax_year}, cutoff=#{cutoff_date}, batch_size=#{batch_size}*****")
      loop do
        batch = fetch_batch
        break if batch.empty?

        archived_ids = archive_batch(batch)
        Rails.logger.info("---Archived #{archived_ids.count} records for #{state_code.upcase}: [#{archived_ids.join(', ')}]---")
      end
      Rails.logger.info("*****Completed archive for state=#{state_code}*****")
    end

    private

    def fetch_batch
      accepted_ids = EfileSubmissionTransition.joins(:efile_submission)
                                              .where(efile_submissions: { data_source_type: intake_class.name })
                                              .where('efile_submission_transitions.created_at <= ?', cutoff_date)
                                              .where(to_state: :accepted, most_recent: true)
                                              .pluck('efile_submissions.data_source_id')

      scope = intake_class.where(id: accepted_ids).where.not(email_address: nil)

      archived_emails = StateFileArchivedIntake
                          .where(state_code: state_code, tax_year: tax_year)
                          .pluck(:email_address)

      scope
        .where.not(email_address: archived_emails)
        .select("DISTINCT ON (email_address) #{intake_class.table_name}.*")
        .order('email_address, created_at DESC')
        .limit(batch_size)
    end

    def archive_batch(intakes)
      intakes.each_with_object([]) do |intake, ids|
        archived_id = archive_intake(intake)
        ids << archived_id if archived_id
      end
    end

    def archive_intake(intake)
      archived = StateFileArchivedIntake.new(
        state_code: state_code,
        tax_year: tax_year,
        hashed_ssn: intake.hashed_ssn,
        email_address: intake.email_address,
        contact_preference: intake.direct_file_data.contact_preference,
        mailing_street: intake.direct_file_data.mailing_street,
        mailing_apartment: intake.direct_file_data.mailing_apartment,
        mailing_city: intake.direct_file_data.mailing_city,
        mailing_state: intake.direct_file_data.mailing_state,
        mailing_zip: intake.direct_file_data.mailing_zip,
      )
      archived.save!

      if intake.submission_pdf.attached?
        archived.submission_pdf.attach(intake.submission_pdf.blob)
      else
        Rails.logger.warn("~~~~~No submission_pdf for intake_id=#{intake.id}~~~~~")
      end

      intake.id
    rescue StandardError => e
      Rails.logger.warn("~~~~~Failed to archive intake_id=#{intake.id}: #{e.message}~~~~~")
      nil
    end

  end
end
