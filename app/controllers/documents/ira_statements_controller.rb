module Documents
  class IraStatementsController < DocumentUploadQuestionController
    def self.document_type
      DocumentTypes::IraStatement
    end
  end
end
