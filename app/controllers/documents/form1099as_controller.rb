module Documents
  class Form1099asController < DocumentUploadQuestionController
    DOCUMENT_TYPE = '1099-A'.freeze

    def self.show?(intake)
      intake.had_debt_forgiven_yes?
    end
  end
end
