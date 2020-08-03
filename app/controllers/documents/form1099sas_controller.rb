module Documents
  class Form1099sasController < DocumentUploadQuestionController
    def self.document_type
      DocumentTypes::Form1099Sa
    end
  end
end
