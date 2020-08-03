module Documents
  class Form1098tsController < DocumentUploadQuestionController
    def self.document_type
      DocumentTypes::Form1098T
    end
  end
end
