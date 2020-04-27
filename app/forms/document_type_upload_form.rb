class DocumentTypeUploadForm < QuestionsForm
  def self.scoped_attributes
    @@scoped_attributes ||= {}
  end
  set_attributes_for :intake, :document

  def initialize(document_type, *args, **kwargs)
    @document_type = document_type
    super(*args, **kwargs)
  end

  def save
    document_file_upload = attributes_for(:intake)[:document]
    if document_file_upload.present?
      document = @intake.documents.create(document_type: @document_type)
      document.upload.attach(document_file_upload)
    end
  end

end
