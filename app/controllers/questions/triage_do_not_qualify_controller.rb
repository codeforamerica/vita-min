module Questions
  class TriageDoNotQualifyController < QuestionsController
    include TriageConcern

    layout "intake"

    def self.show?(intake)
      false
    end

    private

    def illustration_path
      'ineligible.svg'
    end

    def form_class; NullForm; end
  end
end
