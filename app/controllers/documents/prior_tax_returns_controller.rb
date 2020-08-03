module Documents
  class PriorTaxReturnsController < DocumentUploadQuestionController
    def self.document_type
      DocumentTypes::PriorYearTaxReturn
    end
  end
end
