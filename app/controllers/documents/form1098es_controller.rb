module Documents
  class Form1098esController < DocumentUploadQuestionController
    def self.document_type
      DocumentTypes::Form1098E
    end
  end
end
