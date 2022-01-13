module Questions
  class TriageIncomeLevelController < TriageController
    layout "intake"
    skip_before_action :require_triage

    def next_path
      TriageResultService.new(current_triage).after_income_levels || super
    end

    private

    def illustration_path
      "balance-payment.svg"
    end

    def form_params
      super.merge(
        source: session[:source],
        referrer: session[:referrer],
        locale: I18n.locale,
        visitor_id: cookies[:visitor_id],
      )
    end

    def after_update_success
      session[:triage_id] = @form.triage.id
    end
  end
end
