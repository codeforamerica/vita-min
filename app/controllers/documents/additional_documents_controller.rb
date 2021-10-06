module Documents
  class AdditionalDocumentsController < DocumentUploadQuestionController
    before_action :advance_to_ready, only: [:edit]

    def self.show?(_intake)
      true
    end

    def self.document_type
      DocumentTypes::Other
    end

    private

    def advance_to_ready
      current_intake.tax_returns.each { |tr| tr.advance_to(:intake_ready) }
    end

    def illustration_path
      "documents.svg"
    end
  end
end
