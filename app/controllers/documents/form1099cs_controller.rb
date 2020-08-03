module Documents
  class Form1099csController < DocumentUploadQuestionController
    def self.document_type
      DocumentTypes::Form1099C
    end
  end
end
