class RequestedDocumentUploadForm < QuestionsForm
  set_attributes_for :documents_request, :document
  validates :document, file_type_allowed: true

  def initialize(documents_request, *args, **kwargs)
    @documents_request = documents_request
    super(nil, *args, **kwargs)
  end

  def save
    document_file_upload = attributes_for(:documents_request)[:document]
    if document_file_upload.present?
      @documents_request.documents.create(
        uploaded_by: @documents_request.intake.client,
        document_type: DocumentTypes::RequestedLater.key,
        client_id: @documents_request.intake.client_id,
        upload: document_file_upload,
      )
    end
  end
end
