module Questions
  class TriageBacktaxesYearsController < TriageController
    layout "intake"

    private

    def next_path
      TriageResultService.new(current_triage).after_backtaxes_years || super
    end

    private

    def illustration_path; end
  end
end
