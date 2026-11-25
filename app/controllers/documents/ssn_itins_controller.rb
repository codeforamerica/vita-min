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
      intake_transition_to(current_intake, next_intake_state(current_intake))
    end
  end
end
