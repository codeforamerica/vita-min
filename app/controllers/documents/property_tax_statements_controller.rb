module Documents
  class PropertyTaxStatementsController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.paid_local_tax_yes?
    end
  end
end
