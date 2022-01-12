module Questions
  class TriageBacktaxesYearsController < TriageController
    layout "intake"

    private

    def next_path
      if probably_full_service
        Questions::TriageIncomeTypesController.to_path_helper
      else
        super
      end
    end

    private

    def probably_full_service
      [:backtaxes_2018, :backtaxes_2019, :backtaxes_2020].any? { |m| @form.triage.send(m) == "no" } &&
        %w[all_copies some_copies].include?(@form.triage.doc_type) &&
        @form.triage.id_type == "have_paperwork"
    end

    def illustration_path; end
  end
end
