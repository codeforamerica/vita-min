module Documents
  class SelfiesController < DocumentUploadQuestionController
    include GyrDocuments

    before_action :set_required_person_names, only: [:edit, :update]

    def self.document_type
      DocumentTypes::Selfie
    end

    def after_update_success
      advance_to(current_intake, :intake_needs_doc_help)
    end

    def illustration_path
      'ids.svg'
    end
  end
end
