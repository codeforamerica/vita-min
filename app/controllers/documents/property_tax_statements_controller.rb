module Documents
  class PropertyTaxStatementsController < DocumentUploadQuestionController
    def self.document_type
      DocumentTypes::PropertyTaxStatement
    end
  end
end
