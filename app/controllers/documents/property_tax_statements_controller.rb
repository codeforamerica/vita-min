module Documents
  class PropertyTaxStatementsController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.paid_local_tax_yes?
    end

    def self.document_type
      "Property Tax Statement"
    end
  end
end
