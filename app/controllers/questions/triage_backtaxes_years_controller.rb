module Questions
  class TriageBacktaxesYearsController < TriageController
    layout "intake"

    class MinimalForm < Form; end

    def edit
      @form = MinimalForm.new
    end

    private

    def illustration_path; end
  end
end
