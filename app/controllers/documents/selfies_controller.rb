module Documents
  class SelfiesController < DocumentUploadQuestionController
    before_action :set_filer_names, only: [:edit, :update]

    def self.document_type
      DocumentTypes::Selfie
    end

    def illustration_path
      'ids.svg'
    end
  end
end
