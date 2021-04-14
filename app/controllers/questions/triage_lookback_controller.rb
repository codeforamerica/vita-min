module Questions
  class TriageLookbackController < TriageController
    layout "intake"

    private

    def illustration_path
      "hand-holding-cash.svg"
    end

    def next_path
      @form.has_complex_situation? ? triage_arp_questions_path : super
    end
  end
end
