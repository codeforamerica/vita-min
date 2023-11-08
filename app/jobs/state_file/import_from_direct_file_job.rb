module StateFile
  class ImportFromDirectFileJob < ApplicationJob
    def perform(token:, intake:)
      direct_file_xml = IrsApiService.import_federal_data(token)

      intake.update(raw_direct_file_data: direct_file_xml)
      intake.direct_file_data.dependents.each do |direct_file_dependent|
        intake.dependents.create(direct_file_dependent.attributes)
      end

      DfDataTransferJobChannel.broadcast_job_complete(intake)
    end

    def priority
      PRIORITY_LOW
    end
  end
end