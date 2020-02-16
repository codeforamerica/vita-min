module Documents
  class Form1098sController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.paid_mortgage_interest_yes? || intake.paid_local_tax_yes?
    end
  end
end
