module Questions
  class StartWithCurrentYearController < AnonymousIntakeController
    layout "intake"

    private

    def self.form_class
      NullForm
    end
  end
end
