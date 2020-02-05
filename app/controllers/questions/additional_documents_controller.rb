module Questions
  class AdditionalDocumentsController < QuestionsController
    layout "document_upload"

    def section_title
      "Documents"
    end

    def edit
      @documents = current_intake.documents.of_type("Other")
      super
    end

    def update
      @form = form_class.new(current_intake, form_params)
      if @form.valid?
        @form.save
        update_session
      end

      redirect_to action: :edit
    end
  end
end
