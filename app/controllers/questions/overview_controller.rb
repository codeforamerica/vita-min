module Questions
  class OverviewController < AnonymousIntakeController
    layout "intake"

    def illustration_path; end

    def self.form_class
      NullForm
    end
  end
end
