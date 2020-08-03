module Documents
  class Form1095asController < DocumentUploadQuestionController
    def self.document_type
      DocumentTypes::Form1095A
    end
  end
end
