module Documents
  class Form5498sasController < DocumentUploadQuestionController
    DOCUMENT_TYPE = '5498-SA'.freeze

    def self.show?(intake)
      intake.had_hsa_yes?
    end
  end
end
