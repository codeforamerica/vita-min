module Documents
  class CareProviderStatementsController < DocumentUploadQuestionController
    def self.document_type
      DocumentTypes::CareProviderStatement
    end
  end
end
