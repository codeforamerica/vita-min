module Questions
  class TriageIncomeTypesController < TriageController
    layout "intake"

    def self.show?(triage)
      false
    end

    private

    def next_path
      TriageResultService.new(current_triage).after_income_type
    end

    def illustration_path; end
  end
end
