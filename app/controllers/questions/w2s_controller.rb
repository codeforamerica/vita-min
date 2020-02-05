module Questions
  class W2sController < QuestionsController
    layout "document_upload"

    def section_title
      "Documents"
    end

    def edit
      @documents = current_intake.documents.of_type("W-2")
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
