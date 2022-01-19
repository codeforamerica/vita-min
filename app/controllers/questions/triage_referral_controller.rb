module Questions
  class TriageReferralController < TriageController
    layout "intake"

    before_action :redirect_if_income_too_high

    def self.show?(triage)
      false
    end

    private

    def redirect_if_income_too_high
      redirect_to Questions::WelcomeController.to_path_helper if current_triage.income_level_hh_over_73000?
    end

    def illustration_path
      "document-success.svg"
    end

    def form_class; NullForm; end
  end
end
