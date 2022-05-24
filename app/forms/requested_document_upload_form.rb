class RequestedDocumentUploadForm < QuestionsForm
  set_attributes_for :documents_request, :document, :document_type
  validate :instantiate_document

  def initialize(documents_request, *args, **kwargs)
    @documents_request = documents_request
    super(nil, *args, **kwargs)
  end

  def save
    return false unless valid?

    @doc.save!
  end

  private

  def instantiate_document
    document_file_upload = attributes_for(:documents_request)[:document]
    document_type = attributes_for(:documents_request)[:document_type] || DocumentTypes::RequestedLater
    if document_file_upload.present?
      doc = @documents_request.documents.new(
        uploaded_by: @documents_request.client,
        document_type: document_type.key,
        client: @documents_request.client,
        upload: document_file_upload,
      )
    end

    if doc.valid?
      @doc = doc
    else
      doc.errors.map { |error| error.message }.flatten.each { |msg| errors.add(:document, msg) }
    end
  end
end
