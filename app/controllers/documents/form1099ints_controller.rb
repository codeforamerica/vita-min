module Documents
  class Form1099intsController < DocumentUploadQuestionController
    def self.document_type
      DocumentTypes::Form1099Int
    end
  end
end
