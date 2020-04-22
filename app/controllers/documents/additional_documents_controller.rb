module Documents
  class AdditionalDocumentsController < DocumentUploadQuestionController
    def self.document_type
      "Other"
    end
  end
end
