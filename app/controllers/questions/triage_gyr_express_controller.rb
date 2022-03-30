module Questions
  class TriageGyrExpressController < QuestionsController
    # Ideally this should be called TriageGyrCtcController. In Feb 2022, we called CTC "express", and now we keep the
    # old name so the Mixpanel reports don't have to change. Perhaps rename at the end of the 2022 season.
    include TriageConcern

    layout "intake"

    def self.show?(intake)
      false
    end

    private

    def illustration_path; end

    def form_class; NullForm; end
  end
end
