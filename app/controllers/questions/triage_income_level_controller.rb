module Questions
  class TriageIncomeLevelController < TriageController
    layout "intake"
    skip_before_action :require_triage

    def next_path
      case current_triage&.income_level
      when "hh_66000_to_73000"
        return Questions::TriageReferralController.to_path_helper
      when "hh_over_73000"
        return Questions::TriageDoNotQualifyController.to_path_helper
      end

      super
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
