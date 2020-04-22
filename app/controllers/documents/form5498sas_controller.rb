module Documents
  class Form5498sasController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.had_hsa_yes?
    end

    def self.document_type
      "5498-SA"
    end
  end
end
