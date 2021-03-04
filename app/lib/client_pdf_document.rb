class ClientPdfDocument
  def self.create_or_update(output_file:, document_type: , client:, filename: )
    tempfile = output_file
    tempfile.seek(0)
    document = client.documents.find_or_initialize_by(document_type: document_type.key)
    document.update!(
      document_type: document_type.key,
      display_name: filename,
      upload: {
          io: tempfile,
          filename: filename,
          content_type: "application/pdf",
          identify: false
      }
    )
    document
  end
end