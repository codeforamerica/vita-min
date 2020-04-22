module Documents
  class CareProviderStatementsController < DocumentUploadQuestionController
    DOCUMENT_TYPE = 'Care Provider Statement'.freeze

    def self.show?(intake)
      intake.paid_dependent_care_yes?
    end
  end
end
