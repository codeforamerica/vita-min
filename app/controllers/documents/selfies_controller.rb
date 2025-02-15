module Documents
  class SelfiesController < DocumentUploadQuestionController
    before_action :set_required_person_names, only: [:edit, :update]

    def self.document_type
      DocumentTypes::Selfie
    end

    def after_update_success; end

    def illustration_path
      'ids.svg'
    end
  end
end
