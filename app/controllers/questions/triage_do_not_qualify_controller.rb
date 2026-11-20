module Questions
  class TriageDoNotQualifyController < QuestionsController
    include TriageConcern

    layout "intake"

    def self.show?(intake)
      false
    end

    private

    def form_class; NullForm; end
  end
end
