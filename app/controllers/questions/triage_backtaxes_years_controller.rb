module Questions
  class TriageBacktaxesYearsController < TriageController
    layout "intake"

    private

    def next_path
      TriageResultService.new(current_triage).after_backtaxes_years || super
    end

    def illustration_path; end
  end
end
