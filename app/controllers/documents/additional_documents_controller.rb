module Documents
  class AdditionalDocumentsController < DocumentUploadQuestionController
    def self.show?(_intake)
      true
    end

    def self.document_type
      DocumentTypes::Other
    end

    private

    def illustration_path
      "documents.svg"
    end
  end
end
