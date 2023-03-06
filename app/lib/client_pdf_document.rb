class ClientPdfDocument
  def self.create_or_update(output_file:, document_type: , client:, filename:, tax_return: nil)
    tempfile = output_file
    tempfile.seek(0)
    # TODO: after no document_types of "F13614C 2020" change back to => document = client.documents.find_or_initialize_by(document_type: document_type.key)
    document =
      if document_type == DocumentTypes::Form13614C && (client.documents.find_by(document_type: document_type.key) || client.documents.find_by(document_type: "F13614C 2020"))
        client.documents.find_by(document_type: document_type.key) || client.documents.find_by(document_type: "F13614C 2020")
      else
        client.documents.find_or_initialize_by(document_type: document_type.key)
      end
    document.update!(
      document_type: document_type.key,
      display_name: filename,
      upload: {
          io: tempfile,
          filename: filename,
          content_type: "application/pdf",
          identify: false
      },
      tax_return: tax_return
    )
    document
  end
end
