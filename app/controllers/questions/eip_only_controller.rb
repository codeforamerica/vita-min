module Questions
  class EipOnlyController < QuestionsController
    # this is a placeholder until we finish the streamlined eip intake
    layout "question"

    def self.show?(_intake)
      false
    end

    def current_intake
      super || Intake.new
    end

    def illustration_path
      nil
    end
  end
end
