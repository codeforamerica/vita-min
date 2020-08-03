module Documents
  class Form1099miscsController < DocumentUploadQuestionController
    def self.document_type
      DocumentTypes::Form1099Misc
    end
  end
end
