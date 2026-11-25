module Documents
  class AdditionalDocumentsController < DocumentUploadQuestionController
    def self.show?(_intake)
      true
    end

    def self.document_type
      DocumentTypes::Other
    end
  end
end
