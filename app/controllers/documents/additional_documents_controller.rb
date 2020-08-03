module Documents
  class AdditionalDocumentsController < DocumentUploadQuestionController
    def self.document_type
      DocumentTypes::Other
    end
  end
end
