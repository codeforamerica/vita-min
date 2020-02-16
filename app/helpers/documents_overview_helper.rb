module DocumentsOverviewHelper
  def edit_document_path(document_type)
    document_controller = DocumentNavigation::DOCUMENT_CONTROLLERS[document_type]

    unless document_controller
      raise "Missing document type `#{document_type}` from Document::DOCUMENT_CONTROLLERS"
    end

    document_path(document_controller)
  end
end
