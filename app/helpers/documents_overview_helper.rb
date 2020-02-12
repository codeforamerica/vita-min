# frozen_string_literal: true

module DocumentsOverviewHelper
  def edit_document_path(document_type)
    document_controller = Document::DOCUMENT_CONTROLLERS[document_type]

    unless document_controller
      raise "Missing document type `#{document_type}` from Document::DOCUMENT_CONTROLLERS"
    end

    url_for(controller: document_controller.controller_path, action: :edit)
  end
end
