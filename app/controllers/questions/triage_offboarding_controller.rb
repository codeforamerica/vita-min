module Questions
  class TriageOffboardingController < QuestionsController
    include AnonymousIntakeConcern

    layout "intake"

    def edit
      @faq_path = faq_question_path(
        section_key: :about_getyourrefund,
        question_key: :what_if_i_can_t_use_getyourrefund_what_are_my_filing_options
      )
    end

    def self.show?(intake)
      intake.triage_vita_income_ineligible_yes? && intake.triage_income_level_over_89000?
    end

    def next_path
      nil
    end

    private

    def illustration_path
      "no_file.svg"
    end
  end
end
