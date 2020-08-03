module Documents
  class Form1099divsController < DocumentUploadQuestionController
    def self.document_type
      DocumentTypes::Form1099Div
    end
  end
end
