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

    def after_update_success
      next_state = has_all_required_docs?(current_intake) ? :intake_ready : :intake_needs_doc_help
      intake_transition_to(current_intake, next_state)
    end

    def illustration_path
      'ssn-itins.svg'
    end
  end
end
