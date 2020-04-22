module Documents
  class Form1099csController < DocumentUploadQuestionController
    DOCUMENT_TYPE = '1099-C'

    def self.show?(intake)
      intake.had_debt_forgiven_yes?
    end
  end
end
