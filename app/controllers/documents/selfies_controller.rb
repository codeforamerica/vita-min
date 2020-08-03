module Documents
  class SelfiesController < DocumentUploadQuestionController
    before_action :set_filer_names, only: [:edit, :update]

    def self.document_type
      "Selfie"
    end
  end
end
