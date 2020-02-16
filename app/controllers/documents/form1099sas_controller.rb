module Documents
  class Form1099sasController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.had_hsa_yes?
    end
  end
end
