class DocumentTypeUploadForm < QuestionsForm
  set_attributes_for :intake, :document
  validates :document, file_type_allowed: true
  validate :instantiate_document

  def initialize(document_type, *args, **kwargs)
    @document_type = document_type
    super(*args, **kwargs)
  end

  def save
    return false unless valid?

    @doc.save!
  end

  private

  def instantiate_document
    document_file_upload = attributes_for(:intake)[:document]
    if document_file_upload.blank?
      errors.add(:document, I18n.t("validators.file_type"))
      return
    end

    # Rewind to avoid IntegrityError
    document_file_upload.tempfile.rewind
    doc = @intake.documents.new(
        document_type: @document_type,
        client: @intake.client,
        uploaded_by: @intake.client,
        upload: {
          io: document_file_upload.tempfile,
          # Remove non-utf-8 characters from the original filename
          filename: document_file_upload.original_filename.encode("UTF-8", invalid: :replace, replace: ""),
          content_type: document_file_upload.content_type
        }
    )
    if doc.valid?
      @doc = doc
    else
      doc.errors.map { |error| error.message }.flatten.each { |msg| errors.add(:document, msg) }
    end
  end
end
