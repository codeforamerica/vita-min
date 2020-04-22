module Documents
  class Form1099asController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.had_debt_forgiven_yes?
    end

    def self.document_type
      "1099-A"
    end
  end
end
