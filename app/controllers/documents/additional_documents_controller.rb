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
      current_intake.advance_tax_return_statuses_to("intake_ready")
    end
  end
end
