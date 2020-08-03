module Documents
  class W2gsController < DocumentUploadQuestionController
    def self.document_type
      DocumentTypes::W2G
    end
  end
end
