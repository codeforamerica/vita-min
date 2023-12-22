module StateFile
  class ImportFromDirectFileJob < ApplicationJob
    def perform(authorization_code:, intake:)
      return if intake.raw_direct_file_data

      direct_file_json = IrsApiService.import_federal_data(authorization_code, intake.state_code)

      intake.update(
        raw_direct_file_data: direct_file_json['xml'],
        federal_submission_id: direct_file_json['submissionId'],
        federal_return_status: direct_file_json['status']
      )
      intake.update(
        hashed_ssn: SsnHashingService.hash(intake.direct_file_data.primary_ssn)
      )
      intake.synchronize_df_dependents_to_database

      DfDataTransferJobChannel.broadcast_job_complete(intake)
    end

    def priority
      PRIORITY_LOW
    end
  end
end