class RequestedDocumentUploadForm < QuestionsForm
  set_attributes_for :documents_request, :upload, :document_type
  before_validation :instantiate_document
  validate :validate_document

  def initialize(documents_request, *args, **kwargs)
    @documents_request = documents_request
    super(nil, *args, **kwargs)
  end

  def save
    return false unless valid?

    @document.save!
  end

  private

  def validate_document
    errors.copy!(@document.errors) unless @document.valid?
  end

  def instantiate_document
    @upload.tempfile.rewind if @upload.present?
    @document = @documents_request.documents.new(
      document_type: @document_type || DocumentTypes::RequestedLater,
      client: @documents_request.client,
      uploaded_by: @documents_request.client,
      upload: @upload.present? ? {
          io: @upload.tempfile, # Rewind to avoid integrity error
          filename: @upload.original_filename.encode("UTF-8", invalid: :replace, replace: ""), # Remove non-utf-8 characters from the original filename
          content_type: @upload.content_type
      } : nil
    )
  end
end
