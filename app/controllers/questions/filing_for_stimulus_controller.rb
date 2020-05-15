module Questions
  class FilingForStimulusController < QuestionsController
    layout "yes_no_question"

    def next_path
      if current_intake.filing_for_stimulus_yes? && current_intake.already_filed_yes?
        stimulus_recommendation_path
      else
        super
      end
    end
  end
end
