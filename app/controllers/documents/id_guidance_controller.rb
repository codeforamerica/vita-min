module Documents
  class IdGuidanceController < DocumentUploadQuestionController
    layout "intake"

    def edit; end

    def self.document_type
      nil
    end

    def illustration_path
      "id-guidance.svg"
    end
  end
end
