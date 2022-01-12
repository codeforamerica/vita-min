module Questions
  class TriageDoNotQualifyController < TriageController
    layout "intake"

    def self.show(triage)
      false
    end

    private

    def illustration_path
      'question-mark.svg'
    end

    def form_class; NullForm; end
  end
end
