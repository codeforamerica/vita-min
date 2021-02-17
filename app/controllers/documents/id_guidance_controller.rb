module Documents
  class IdGuidanceController < DocumentUploadQuestionController
    layout "intake"

    def edit; end

    def self.document_type
      nil
    end
  end
end
