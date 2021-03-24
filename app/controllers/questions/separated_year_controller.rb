module Questions
  class SeparatedYearController < AuthenticatedIntakeController
    layout "intake"

    def self.show?(intake)
      intake.separated_yes?
    end

    def illustration_path
      "calendar.svg"
    end
  end
end
