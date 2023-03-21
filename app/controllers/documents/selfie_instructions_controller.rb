module Documents
  class SelfieInstructionsController < DocumentUploadQuestionController
    layout "intake"

    def self.show?(intake)
      !IdVerificationExperimentService.new(intake).skip_selfies?
    end

    def self.document_type
      nil
    end
  end
end
