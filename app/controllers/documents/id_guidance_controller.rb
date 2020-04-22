module Documents
  class IdGuidanceController < DocumentUploadQuestionController
    layout "application"

    def edit; end

    def self.document_type
      nil
    end
  end
end
