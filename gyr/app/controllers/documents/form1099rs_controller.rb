module Documents
  class Form1099rsController < DocumentUploadQuestionController
    def self.document_type
      DocumentTypes::Form1099R
    end
  end
end
