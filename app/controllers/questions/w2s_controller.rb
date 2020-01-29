module Questions
  class W2sController < QuestionsController
    layout "yes_no_question"

    def section_title
      "Documents"
    end

    def update
      @form = form_class.new(current_intake, form_params)
      if @form.valid?
        @form.save
        update_session
      end
      render :edit
    end
  end
end