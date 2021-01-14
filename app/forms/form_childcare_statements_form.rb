class FormChildcareStatementsForm < QuestionsForm
  set_attributes_for :intake, :document

  def save
    document_file_upload = attributes_for(:intake)[:document]
    return unless document_file_upload.present?

    @intake.documents.create(document_type: "childcare_statement", upload: document_file_upload)
  end
end
