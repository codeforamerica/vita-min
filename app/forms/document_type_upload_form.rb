class DocumentTypeUploadForm < QuestionsForm
  set_attributes_for :intake, :document
  validates :document, file_type_allowed: true

  def initialize(document_type, *args, **kwargs)
    @document_type = document_type
    super(*args, **kwargs)
  end

  def save
    document_file_upload = attributes_for(:intake)[:document]
    if document_file_upload.present?
      doc = @intake.documents.new(
        document_type: @document_type,
        client: @intake.client,
        uploaded_by: @intake.client
      )
      # Rewind to avoid IntegrityError
      document_file_upload.tempfile.rewind
      # Remove non-utf-8 characters from the original filename
      doc.upload.attach(
        io: document_file_upload.tempfile,
        filename: document_file_upload.original_filename.encode("UTF-8", invalid: :replace, replace: ""),
        content_type: document_file_upload.content_type
      )
      doc.save!
    end
  end
end
