# frozen_string_literal: true

module Questions
  class DocumentsOverviewController < QuestionsController
    layout "application"

    def edit
      @documents = current_intake.documents
    end

    def section_title
      "Documents"
    end
  end
end
