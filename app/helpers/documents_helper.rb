module DocumentsHelper
  MUST_HAVE_DOC_TYPES= [
    "ID",
    "Spouse ID",
    "Primary SSN or ITIN",
    "Spouse SSN or ITIN",
    "1095-A",
    "1099-R",
    "SSN or ITIN",
  ]

  def must_have?(document_type)
    MUST_HAVE_DOC_TYPES.include?(document_type)
  end

  def might_have?(document_type)
    !MUST_HAVE_DOC_TYPES.include?(document_type)
  end

  def any_might_have_docs?(doc_types)
    doc_types.any? { |type| might_have?(type) }
  end

  def any_must_have_docs?(doc_types)
    doc_types.any? { |type| must_have?(type) }
  end
end
