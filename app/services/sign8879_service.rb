class Sign8879Service
  def self.create(tax_return)
    unsigned8879 = tax_return.documents.find_by(document_type: DocumentTypes::UnsignedForm8879.key)

    document_writer = WriteToPdfDocumentService.new(unsigned8879, DocumentTypes::UnsignedForm8879)

    document_writer.write(:primary_signature, tax_return.primary_signature)
    document_writer.write(:primary_signed_on, tax_return.primary_signed_at.strftime("%m/%d/%Y"))

    if tax_return.spouse_has_signed?
      document_writer.write(:spouse_signature, tax_return.spouse_signature)
      document_writer.write(:spouse_signed_on, tax_return.spouse_signed_at.strftime("%m/%d/%Y"))
    end

    tempfile = document_writer.tempfile_output

    tax_return.documents.create!(
      client: tax_return.client,
      uploaded_by: tax_return.client,
      document_type: DocumentTypes::CompletedForm8879.key,
      display_name: "Taxpayer Signed #{tax_return.year} 8879",
      upload: {
        io: tempfile,
        filename: "Signed-f8879.pdf",
        content_type: "application/pdf",
        identify: false
      }
    )
  end
end