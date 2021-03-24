module Questions
  class DivorcedYearController < AuthenticatedIntakeController
    layout "intake"

    def self.show?(intake)
      intake.divorced_yes?
    end

    def illustration_path
      "calendar.svg"
    end
  end
end
