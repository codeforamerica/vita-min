module Documents
  class Form1099ssController < DocumentUploadQuestionController
    def self.document_type
      DocumentTypes::Form1099S
    end
  end
end
