module DocumentsOverviewHelper
  def edit_document_path(document_type)
    unless DocumentNavigation::DOCUMENT_TYPES.include?(document_type)
      raise "Missing document type `#{document_type}` from Document::DOCUMENT_CONTROLLERS"
    end

    document_controller = DocumentNavigation.controller_for(document_type)

    document_path(document_controller)
  end
end
