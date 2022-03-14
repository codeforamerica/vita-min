module Questions
  class TriageGyrIdsController < QuestionsController
    include TriageConcern
    include PreviousPathIsBackConcern

    layout "intake"

    def self.show?(intake)
      true
    end

    private

    def illustration_path
      "id-guidance.svg"
    end

    def form_class; NullForm; end
  end
end
