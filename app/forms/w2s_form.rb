class W2sForm < QuestionsForm
  set_attributes_for :intake, :documents

  def save
    document_file_upload = attributes_for(:intake)[:documents]
    document = @intake.documents.create(document_type: "W-2")
    document.upload.attach(document_file_upload)
  end

  def self.existing_attributes(intake)
    HashWithIndifferentAccess.new({documents: intake.documents.where(document_type: "W-2")})
  end
end