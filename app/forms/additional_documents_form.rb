class AdditionalDocumentsForm < QuestionsForm
  set_attributes_for :intake, :document

  def save
    document_file_upload = attributes_for(:intake)[:document]
    if document_file_upload.present?
      document = @intake.documents.create(document_type: "Other")
      document.upload.attach(document_file_upload)
    end
  end
end
