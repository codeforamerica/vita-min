module SubmissionBuilder
  # One entry of a return builder's #supported_documents, e.g.
  #   { xml: Documents::Irs1040, pdf: PdfFiller::Irs1040Pdf, include: true, kwargs: { ... } }
  # Unknown keys raise ArgumentError rather than being silently ignored.
  SupportedDocument = Data.define(:xml, :pdf, :include, :kwargs) do
    def initialize(xml: nil, pdf: nil, include: false, kwargs: nil)
      super(xml:, pdf:, include:, kwargs: kwargs || {})
    end
  end
end
