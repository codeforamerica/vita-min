class RequiredDocumentUploadForm < DocumentTypeUploadForm
  set_attributes_for :submit, :next_step

  validate :has_documents, if: :next_step

  def has_documents
    if intake.documents.of_type(@document_type).count == 0
      errors.add(:document, "Please upload at least 1 document")
    end
  end

end
