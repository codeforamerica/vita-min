module Documents
  class IdsController < DocumentUploadQuestionController
    before_action :set_filer_names, only: [:edit, :update]

    def self.document_type
      "ID"
    end
  end
end
