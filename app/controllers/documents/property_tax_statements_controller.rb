module Documents
  class PropertyTaxStatementsController < DocumentUploadQuestionController
    DOCUMENT_TYPE = 'Property Tax Statement'.freeze

    def self.show?(intake)
      intake.paid_local_tax_yes?
    end
  end
end
