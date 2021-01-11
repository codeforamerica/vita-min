class Sign8879Service
  def initialize(unsigned8879)
    raise StandardError, 'Document is not Form 8879' unless unsigned8879.document_type == DocumentTypes::Form8879.key

    @tax_return = unsigned8879.tax_return
    @document_writer = WriteToDocumentService.new(unsigned8879, DocumentTypes::Form8879)
  end

  def sign_and_save
    write_primary_signature
    save_as_document
  end

  private

  def save_as_document
    tempfile = @document_writer.tempfile_output
    @tax_return.documents.create!(
      client: @tax_return.client,
      document_type: DocumentTypes::CompletedForm8879.key,
      display_name: "Taxpayer Signed #{@tax_return.year} 8879",
      upload: {
        io: tempfile,
        filename: "Signed-f8879.pdf",
        content_type: "application/pdf",
        identify: false
      }
    )
  end

  def write_primary_signature
    @document_writer.write(:primary_signature, @tax_return.client.legal_name)
    @document_writer.write(:primary_signed_on, Date.today.strftime("%m/%d/%Y"))
  end
end