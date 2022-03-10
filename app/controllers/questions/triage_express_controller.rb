module Questions
  class TriageExpressController < QuestionsController
    include TriageConcern

    layout "intake"

    def self.show?(intake)
      false
    end

    private

    def illustration_path; end

    def form_class; NullForm; end
  end
end
