module Documents
  class IdsController < DocumentUploadQuestionController
    before_action :set_filer_names, only: [:edit, :update]

    def self.document_type
      DocumentTypes::Identity
    end

    def illustration_path
      "ids.svg"
    end
  end
end
