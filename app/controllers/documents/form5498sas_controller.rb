module Documents
  class Form5498sasController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.had_hsa_yes?
    end
  end
end
