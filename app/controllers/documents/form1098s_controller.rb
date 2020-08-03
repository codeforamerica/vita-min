module Documents
  class Form1098sController < DocumentUploadQuestionController
    def self.document_type
      DocumentTypes::Form1098
    end
  end
end
