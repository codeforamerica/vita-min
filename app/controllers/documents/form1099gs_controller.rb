module Documents
  class Form1099gsController < DocumentUploadQuestionController
    def self.document_type
      DocumentTypes::Form1099G
    end
  end
end
