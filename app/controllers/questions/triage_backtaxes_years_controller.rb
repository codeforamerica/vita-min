module Questions
  class TriageBacktaxesYearsController < TriageController
    layout "intake"

    private

    def next_path
      if [:backtaxes_2018, :backtaxes_2019, :backtaxes_2020].any? { |m| @form.triage.send(m) == "no" } && %w[all_copies some_copies].include?(@form.triage.doc_type)
        Questions::TriageIncomeTypesController.to_path_helper
      else
        super
      end
    end

    def illustration_path; end
  end
end
