class ClientPdfDocument
  def self.create_or_update(output_file:, document_type: , client:, filename:, tax_return: nil)
    tempfile = output_file
    tempfile.seek(0)
    # TODO: after removing all document_types of "F13614C 2020" change back to => document = client.documents.find_or_initialize_by(document_type: document_type.key)
    keys = [document_type.key]
    keys << "F13614C 2020" if document_type == DocumentTypes::Form13614C
    document =  client.documents.find_or_initialize_by(document_type: keys)
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
