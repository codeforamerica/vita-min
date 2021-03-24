# This is a wrapper around CombinePDF that allows you to pass in a
# Document object we need to write new information to, and write to it.
class WriteToPdfDocumentService
  # @param document Document
  # @param document_type_klass DocumentType::ALL_TYPES type
  #
  def initialize(document, document_type_klass)
    @document = document
    @document_klass = document_type_klass
    # Passing allow_optional_content flag to turn off optional content protection.
    # We may need to reassess if this results in malformed final files, but in early testing on complex pdfs seems fine.
    # https://github.com/boazsegev/combine_pdf/issues/28
    @combine_pdf = CombinePDF.parse(streamed_original, { allow_optional_content: true })
  end

  def tempfile_output
    tempfile = Tempfile.new(
      [@document_klass.key, ".pdf"],
      "tmp/",
      binmode: true
    )

    tempfile.write(@combine_pdf.to_pdf)
    tempfile.rewind
    tempfile
  end

  def write(location_attr, text)
    attrs = @document_klass.writeable_locations[location_attr]

    raise UnknownDocumentAttributeError, "Can't write to document. #{location_attr} not found on #{@document_klass}." unless attrs

    page_index = attrs.delete(:page) || 0

    @combine_pdf.pages[page_index].textbox(
      text,
      **field_defaults,
      **attrs
    )
  end

  private

  # Creates an IO stream from tempfile
  # from an ActiveStorage::Attachment
  # so that it can be parsed by CombinePDF#parse
  #
  def streamed_original
    temp = Tempfile.new(
        [@document_klass.key, ".pdf"],
        "/tmp",
        binmode: true
    )
    temp.write(@document.upload.download)
    temp.rewind
    IO.read(temp)
  end

  def field_defaults
    {
        text_align: "left",
        text_valign: "top",
        font_size: 12,
        height: 10,
        width: 400
    }
  end

  class UnknownDocumentAttributeError < StandardError; end
end
