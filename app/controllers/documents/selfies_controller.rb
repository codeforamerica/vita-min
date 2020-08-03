module Documents
  class SelfiesController < DocumentUploadQuestionController
    before_action :set_filer_names, only: [:edit, :update]

    def self.document_type
      DocumentTypes::Selfie
    end
  end
end
