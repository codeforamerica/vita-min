module Documents
  class Form1099csController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.had_debt_forgiven_yes?
    end

    def self.document_type
      "1099-C"
    end
  end
end
