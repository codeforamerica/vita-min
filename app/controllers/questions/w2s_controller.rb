module Questions
  class W2sController < QuestionsController
    layout "application"

    def section_title
      "Documents"
    end

    def edit
      @documents = current_intake.documents.where(document_type: "W-2")
      super
    end

    def update
      @form = form_class.new(current_intake, form_params)
      if @form.valid?
        @form.save
        update_session
      end

      redirect_to w2s_questions_path
    end
  end
end