class Sign8879Service
  def self.create(tax_return)
    unsigned8879s = tax_return.documents.where(document_type: DocumentTypes::UnsignedForm8879.key)
    unsigned8879s.each_with_index do |unsigned8879, i|
      document_writer = WriteToPdfDocumentService.new(unsigned8879, DocumentTypes::UnsignedForm8879)

      document_writer.write(:primary_signature, tax_return.primary_signature)
      document_writer.write(:primary_signed_on, tax_return.primary_signed_at.strftime("%m/%d/%Y"))

      if tax_return.spouse_has_signed_8879?
        document_writer.write(:spouse_signature, tax_return.spouse_signature)
        document_writer.write(:spouse_signed_on, tax_return.spouse_signed_at.strftime("%m/%d/%Y"))
      end

      tempfile = document_writer.tempfile_output
      tempfile.seek(0)

      display_name = unsigned8879.display_name + " (Signed)"
      filename = unsigned8879s.length == 1 ? "Signed-f8879.pdf" : "Signed-f8879-#{i + 1}.pdf"

      unsigned8879.update!(
        uploaded_by: tax_return.client,
        document_type: DocumentTypes::CompletedForm8879.key,
        display_name: display_name,
        upload: {
          io: tempfile,
          filename: filename,
          content_type: "application/pdf",
          identify: false
        }
      )
    end
  end
end