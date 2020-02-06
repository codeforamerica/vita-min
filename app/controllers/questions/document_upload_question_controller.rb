module Questions
  class DocumentUploadQuestionController < QuestionsController
    layout "document_upload"

    def document_type
      raise NotImplementedError,
        "#{self.class.name} must implement `#document_type` (e.g. return \"W-2\")"
    end

    def section_title
      "Documents"
    end

    def edit
      @documents = current_intake.documents.of_type(document_type)
      super
    end

    def update
      @form = form_class.new(current_intake, form_params)
      if @form.valid?
        form_saved = @form.save
        update_session
      end

      redirect_to action: :edit
    end
  end
end
