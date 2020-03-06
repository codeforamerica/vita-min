module DocumentsHelper
  MUST_HAVE_DOC_TYPES= [
    "1095-A",
    "1099-R",
    "SSN or ITIN",
  ]

  MIGHT_HAVE_DOC_TYPES = [
    "W-2",
    "1098",
    "1098-E",
    "1098-T",
    "1099-A",
    "1099-B",
    "1099-C",
    "1099-DIV",
    "1099-INT",
    "1099-K",
    "1099-MISC",
    "1099-S",
    "1099-SA",
    "1099-G",
    "5498-SA",
    "IRA Statement",
    "RRB-1099",
    "SSA-1099",
    "Student Account Statement",
    "Childcare Statement",
    "W-2G",
    "2018 Tax Return",
    "Other",
  ]

  def must_have?(document_type)
    MUST_HAVE_DOC_TYPES.include?(document_type)
  end

  def might_have?(document_type)
    MIGHT_HAVE_DOC_TYPES.include?(document_type)
  end

  def any_might_have_docs?(doc_types)
    doc_types.any? { |type| might_have?(type) }
  end

  def any_must_have_docs?(doc_types)
    doc_types.any? { |type| must_have?(type) }
  end
end
