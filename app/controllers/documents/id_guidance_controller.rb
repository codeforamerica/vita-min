module Documents
  class IdGuidanceController < DocumentUploadQuestionController
    layout "question"

    def edit; end

    def self.document_type
      nil
    end
  end
end
