module Documents
  class Form1099sasController < DocumentUploadQuestionController
    DOCUMENT_TYPE = '1099-SA'.freeze

    def self.show?(intake)
      intake.had_hsa_yes?
    end
  end
end
