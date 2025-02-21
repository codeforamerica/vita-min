module Documents
  class SsnItinsController < DocumentUploadQuestionController
    include GyrDocuments

    before_action :set_required_person_names, only: [:edit, :update]

    def self.displayed_document_types
      DocumentTypes::SECONDARY_IDENTITY_TYPES.map(&:key)
    end

    def self.document_type
      DocumentTypes::SsnItin
    end

    def documents
      if IdVerificationExperimentService.new(current_intake).show_expanded_id?
        super.where(person: :primary)
      else
        super
      end
    end

    def selectable_document_types
      if IdVerificationExperimentService.new(current_intake).show_expanded_id?
        (DocumentTypes::SECONDARY_IDENTITY_TYPES - [DocumentTypes::SsnItin]).map { |doc_type| [doc_type.translated_label(I18n.locale), doc_type.key] }
      end
    end

    def after_update_success
      transition_to = has_all_required_docs?(current_intake) ? :intake_ready : :intake_needs_doc_help
      advance_to(current_intake, transition_to)
    end

    def form_params
      if IdVerificationExperimentService.new(current_intake).show_expanded_id?
        super.merge(person: :primary)
      else
        super
      end
    end

    def illustration_path
      'ssn-itins.svg'
    end
  end
end
