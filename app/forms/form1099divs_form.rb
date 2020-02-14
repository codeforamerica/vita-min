# frozen_string_literal: true

class Form1099divsForm < QuestionsForm
  set_attributes_for :intake, :document

  def save
    document_file_upload = attributes_for(:intake)[:document]
    return unless document_file_upload.present?

    document = @intake.documents.create(document_type: "1099-DIV")
    document.upload.attach(document_file_upload)
  end
end
