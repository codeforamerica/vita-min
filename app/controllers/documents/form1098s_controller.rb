module Documents
  class Form1098sController < DocumentUploadQuestionController
    DOCUMENT_TYPE = '1098'

    def self.show?(intake)
      intake.paid_mortgage_interest_yes? || intake.paid_local_tax_yes?
    end
  end
end
