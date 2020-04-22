module Documents
  class CareProviderStatementsController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.paid_dependent_care_yes?
    end

    def self.document_type
      "Care Provider Statement"
    end
  end
end
