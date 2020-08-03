module Documents
  class Form1099ksController < DocumentUploadQuestionController
    def self.document_type
      DocumentTypes::Form1099K
    end
  end
end
