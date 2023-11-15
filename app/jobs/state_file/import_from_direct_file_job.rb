module StateFile
  class ImportFromDirectFileJob < ApplicationJob
    def perform(token:, intake:)
      return if intake.raw_direct_file_data

      direct_file_xml = IrsApiService.import_federal_data(token, intake.state_code)

      intake.update(raw_direct_file_data: direct_file_xml)
      intake.direct_file_data.dependents.each do |direct_file_dependent|
        dependent = intake.dependents.find_or_initialize_by(ssn: direct_file_dependent.ssn)
        dependent.assign_attributes(direct_file_dependent.attributes)
        dependent.save
      end

      DfDataTransferJobChannel.broadcast_job_complete(intake)
    end

    def priority
      PRIORITY_LOW
    end
  end
end