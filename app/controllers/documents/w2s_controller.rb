module Documents
  class W2sController < DocumentUploadQuestionController
    def self.document_type
      DocumentTypes::W2
    end
  end
end
