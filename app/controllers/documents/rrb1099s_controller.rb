module Documents
  class Rrb1099sController < DocumentUploadQuestionController
    def self.document_type
      DocumentTypes::Rrb1099
    end
  end
end
