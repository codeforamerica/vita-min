module StateFile
  class ImportFromDirectFileJob < ApplicationJob
    def perform(authorization_code:, intake:)
      intake.with_lock("FOR UPDATE NOWAIT") do
        return if intake.raw_direct_file_data

        direct_file_json = IrsApiService.import_federal_data(authorization_code, intake.state_code)

        if direct_file_json.blank?
          raise StandardError, "Direct file data was not transferred for intake #{intake.state_code}#{intake.id}."
        end

        intake.update(
          raw_direct_file_data: direct_file_json['xml'],
          raw_direct_file_intake_data: direct_file_json['directFileData'],
          federal_submission_id: direct_file_json['submissionId'],
          federal_return_status: direct_file_json['status'],
          df_data_imported_at: Time.now
        )
        intake.update(
          hashed_ssn: SsnHashingService.hash(intake.direct_file_data.primary_ssn)
        )

        required_fields = [:raw_direct_file_data, :raw_direct_file_intake_data, :federal_submission_id, :federal_return_status, :hashed_ssn]
        missing_fields = required_fields.select { |field| intake.send(field).blank? }
        if missing_fields.any?
          raise StandardError, "Missing required fields: #{missing_fields.join(', ')}"
        end

        intake.synchronize_df_dependents_to_database
        intake.synchronize_df_1099_rs_to_database
        intake.synchronize_df_w2s_to_database
        intake.synchronize_filers_to_database

        intake.update(df_data_import_succeeded_at: DateTime.now)
      ensure
        DfDataTransferJobChannel.broadcast_job_complete(intake)
      end
    rescue ActiveRecord::LockWaitTimeout => e
      Rails.logger.error("Attempted to run StateFile::ImportForDirectFileJob for an intake while it was already running for that intake!")
      raise e
    rescue StandardError => e
      Rails.logger.error(e)
      intake.df_data_import_errors << DfDataImportError.new(message: e.to_s)
      raise e
    end

    def priority
      PRIORITY_HIGH
    end
  end
end