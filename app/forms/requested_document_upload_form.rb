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
      document = @documents_request.documents.create(document_type: "Requested Later", intake_id: @documents_request.intake.id)
      document.upload.attach(document_file_upload)
    end
  end
end
