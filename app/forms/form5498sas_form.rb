class Form5498sasForm < QuestionsForm
  set_attributes_for :intake, :document

  def save
    document_file_upload = attributes_for(:intake)[:document]
    return unless document_file_upload.present?

    document = @intake.documents.create(document_type: "5498-SA")
    document.upload.attach(document_file_upload)
  end
end
