module Questions
  class EipMaybeIneligibleController < QuestionsController
    def self.show?(intake)
      !intake.eligible_for_eip_only?
    end

    def self.form_class
      NullForm
    end

    def illustration_path
      "ineligible.svg"
    end
  end
end
