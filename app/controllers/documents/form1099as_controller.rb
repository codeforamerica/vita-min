module Documents
  class Form1099asController < DocumentUploadQuestionController
    def self.document_type
      DocumentTypes::Form1099A
    end
  end
end
