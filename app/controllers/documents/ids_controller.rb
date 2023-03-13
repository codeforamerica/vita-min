module Documents
  class IdsController < DocumentUploadQuestionController
    before_action :set_required_person_names, only: [:edit, :update]

    def self.displayed_document_types
      DocumentTypes::IDENTITY_TYPES.map(&:key)
    end

    def self.document_type
      DocumentTypes::Identity
    end

    def after_update_success
      current_intake.tax_returns.each do |tax_return|
        tax_return.advance_to(:intake_needs_doc_help)
      end
    end

    def illustration_path
      "ids.svg"
    end
  end
end
