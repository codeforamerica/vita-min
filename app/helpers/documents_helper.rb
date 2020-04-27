module DocumentsHelper
  # We want to exclude identity docs from the list of docs that the user might
  # or must have.
  IDENTITY_DOC_TYPES = [
    "ID",
    "SSN or ITIN",
    "Selfie",
    "Other"
  ]

  MUST_HAVE_DOC_TYPES = [
    "1095-A",
    "1099-R",
  ]

  def must_have?(document_type)
    return false if IDENTITY_DOC_TYPES.include?(document_type)

    MUST_HAVE_DOC_TYPES.include?(document_type)
  end

  def might_have?(document_type)
    return false if IDENTITY_DOC_TYPES.include?(document_type)

    !MUST_HAVE_DOC_TYPES.include?(document_type)
  end

  def any_might_have_docs?(doc_types)
    doc_types.any? { |type| might_have?(type) }
  end

  def any_must_have_docs?(doc_types)
    doc_types.any? { |type| must_have?(type) }
  end

  def required_document_next_path
    if @documents.empty?
      current_path(submitted_with_no_docs: true)
    else
      next_path
    end
  end

  def display_validation_error?
    params[:submitted_with_no_docs]
  end
end
