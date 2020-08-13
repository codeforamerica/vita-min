module Questions
  class EipMaybeIneligibleController < QuestionsController
    def self.show?(_intake)
      false
    end

    def self.form_class
      NullForm
    end

    def illustration_path
      "eip-check.svg"
    end
  end
end
