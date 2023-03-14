class DocumentTypeUploadForm < QuestionsForm
  set_attributes_for :intake, :upload, :document_type, :person
  before_validation :instantiate_document
  validate :validate_document

  def initialize(document_type, *args, **kwargs)
    @default_document_type = document_type
    super(*args, **kwargs)
  end

  def save
    return false unless valid?

    @document.save!
  end

  private

  def instantiate_document
    @upload.tempfile.rewind if @upload.present?
    @document = @intake.documents.new(
      person: person || :unfilled,
      document_type: @document_type || @default_document_type,
      client: @intake.client,
      uploaded_by: @intake.client,
      upload: @upload.present? ? {
        io: @upload.tempfile, # Rewind to avoid integrity error
        filename: @upload.original_filename.encode("UTF-8", invalid: :replace, replace: ""), # Remove non-utf-8 characters from the original filename
        content_type: @upload.content_type
      } : nil
    )
  end

  def validate_document
    errors.copy!(@document.errors) unless @document.valid?
  end
end
