module Documents
  class AdditionalDocumentsController < DocumentUploadQuestionController
    DOCUMENT_TYPE = 'Other'.freeze

    def self.show?(_)
      true
    end
  end
end
