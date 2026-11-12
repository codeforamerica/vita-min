module Questions
  class TriageGyrController < QuestionsController
    include TriageConcern

    layout "intake"

    def self.show?(intake)
      false
    end

    private

    def form_class; NullForm; end
  end
end
