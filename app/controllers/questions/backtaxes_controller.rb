module Questions
  class BacktaxesController < QuestionsController
    include AnonymousIntakeConcern
    layout "intake"

    private

    def illustration_path
      "calendar.svg"
    end

  end
end
