module DocumentsOverviewHelper
  def edit_document_path_for(document_type)
    document_controller = DocumentNavigation.document_controller_for_type(document_type)

    unless document_controller
      raise "Missing DocumentNavigation::FLOW controller that returns `#{document_type}` from `self.document_type`"
    end

    document_path(document_controller)
  end
end
