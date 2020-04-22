module Documents
  class Form1099sasController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.had_hsa_yes?
    end

    def self.document_type
      "1099-SA"
    end
  end
end
