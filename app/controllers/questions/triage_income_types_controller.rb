module Questions
  class TriageIncomeTypesController < TriageController
    layout "intake"

    private

    def next_path
      TriageResultService.new(current_triage).after_income_type || super
    end

    def illustration_path; end
  end
end
