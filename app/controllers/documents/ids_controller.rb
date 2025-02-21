module Documents
  class IdsController < DocumentUploadQuestionController
    include GyrDocuments

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
      if IdVerificationExperimentService.new(current_intake).show_expanded_id?
        super.where(person: :primary)
      else
        super
      end
    end

    def form_params
      if IdVerificationExperimentService.new(current_intake).show_expanded_id?
        super.merge(person: :primary)
      else
        super
      end
    end

    def after_update_success
      advance_to(current_intake, :intake_needs_doc_help)
    end

    def illustration_path
      "ids.svg"
    end
  end
end
