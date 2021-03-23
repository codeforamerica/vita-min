module Portal
  class DocumentsForm < QuestionsForm
    set_attributes_for :documents, :document
    validates :document, file_type_allowed: true

    def initialize(client, *args, **kwargs)
      @client = client
      super(nil, *args, **kwargs)
    end

    def save
      document_file_upload = attributes_for(:documents)[:document]
      if document_file_upload.present?
        @client.documents.create(
          uploaded_by: @client,
          document_type: DocumentTypes::RequestedLater.key,
          client: @client,
          upload: document_file_upload,
        )
      end
    end
  end
end
