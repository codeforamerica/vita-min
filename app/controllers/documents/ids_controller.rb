module Documents
  class IdsController < DocumentUploadQuestionController
    before_action :set_required_person_names, only: [:edit, :update]

    def self.displayed_document_types
      DocumentTypes::IDENTITY_TYPES.map(&:key)
    end

    def self.document_type
      DocumentTypes::Identity
    end

    def selectable_document_types
      if IdVerificationExperimentService.new(current_intake).show_expanded_id?
        (DocumentTypes::IDENTITY_TYPES - [DocumentTypes::Identity]).map { |doc_type| [doc_type.translated_label(I18n.locale), doc_type.key] }
      end
    end

    def documents
      current_intake.documents.of_type(self.class.displayed_document_types).where(person: :primary)
    end

    def form_params
      super.merge(person: :primary)
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
