module Documents
  class Form5498sasController < DocumentUploadQuestionController
    def self.document_type
      DocumentTypes::Form5498Sa
    end
  end
end
