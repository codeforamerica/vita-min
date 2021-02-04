class HeicToJpgJob < ApplicationJob
  def perform(document_id)
    document = Document.find(document_id)
    document.convert_heic_upload_to_jpg!
  end
end