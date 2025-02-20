module StateFile
  class ImportFromDirectFileJob < ApplicationJob
    def perform(authorization_code:, intake:)
      return if intake.raw_direct_file_data

      begin
        direct_file_json = IrsApiService.import_federal_data(authorization_code, intake.state_code)

        if direct_file_json.blank?
          raise StandardError, "Direct file data was not transferred for intake #{intake.state_code} #{intake.id}."
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

        # TODO: Add raw_direct_file_intake_data into the required_fields array

        required_fields = [:raw_direct_file_data, :federal_submission_id, :federal_return_status, :hashed_ssn]
        missing_fields = required_fields.select { |field| intake.send(field).blank? }
        if missing_fields.any?
          raise StandardError, "Missing required fields: #{missing_fields.join(', ')}"
        end

        intake.synchronize_df_dependents_to_database
        intake.synchronize_df_1099_rs_to_database
        intake.synchronize_df_w2s_to_database
        intake.synchronize_filers_to_database

        intake.update(df_data_import_succeeded_at: DateTime.now)

      rescue => err
        Rails.logger.error(err)
        intake.df_data_import_errors << DfDataImportError.new(message: err.to_s)
      end

      # removing duplicate associations here because sometimes we create duplicate records during data import
      # future work will prevent this issue from happening and this can be removed
      remove_duplicate_w2s(intake)
      remove_duplicate_dependents(intake)

      DfDataTransferJobChannel.broadcast_job_complete(intake)
    end

    def priority
      PRIORITY_LOW
    end

    private

    def remove_dups(intake, collection, identifying_attribute_name)
      values = []
      collection.each do |record|
        value = record.send(identifying_attribute_name)
        if values.include?(value)
          Rails.logger.info("ImportFromDirectFileJob removing duplicates #{record.class&.name} for #{intake&.state_code} #{intake&.id}")
          record.destroy!
        else
          values.push(value)
        end
      end
    end

    def remove_duplicate_w2s(intake)
      remove_dups(intake, intake.state_file_w2s, :w2_index)
    end

    def remove_duplicate_dependents(intake)
      remove_dups(intake, intake.dependents, :ssn)
    end
  end
end