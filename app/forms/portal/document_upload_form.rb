module Portal
  class DocumentUploadForm < QuestionsForm
    set_attributes_for :intake, :upload, :document_type
    before_validation :instantiate_document
    validate :validate_document

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
      @document = intake.documents.new(
        document_type: @document_type,
        client: intake.client,
        uploaded_by: intake.client,
        upload: @upload.present? ? {
            io: @upload.tempfile, # Rewind to avoid integrity error
            filename: @upload.original_filename.encode("UTF-8", invalid: :replace, replace: ""), # Remove non-utf-8 characters from the original filename
            content_type: @upload.content_type
        } : nil
      )
    end
  end
end
