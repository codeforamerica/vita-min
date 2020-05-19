module Questions
  class ReturningClientController < QuestionsController
    layout "application"

    def self.show?(intake)
      DuplicateIntakeGuard.new(intake).has_duplicate?
    end

    private

    def form_class
      NullForm
    end
  end
end
