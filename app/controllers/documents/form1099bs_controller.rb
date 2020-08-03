module Documents
  class Form1099bsController < DocumentUploadQuestionController
    def self.document_type
      DocumentTypes::Form1099B
    end
  end
end
