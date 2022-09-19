module Ctc
  module Questions
    class W2sController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake)
        return unless Flipper.enabled?(:eitc)

        benefits_eligibility = Efile::BenefitsEligibility.new(tax_return: intake.default_tax_return, dependents: intake.dependents)
        benefits_eligibility.claiming_and_qualified_for_eitc_pre_w2s?
      end

      def add_w2_later
        analytics_journey = AnalyticsJourney.find_or_initialize_by(client: current_intake.client)
        analytics_journey.update(w2_logout_add_later: Time.now)

        send_mixpanel_event(event_name: "w2_logout_add_later", data: MixpanelService.data_from([current_intake.client, current_intake]))

        sign_out current_intake.client
      end

      def next_path
        if current_intake.had_w2s_yes?
          Ctc::Questions::W2s::EmployeeInfoController.to_path_helper(id: current_intake.new_record_token)
        elsif current_intake.had_w2s_no?
          form_navigation.next(Ctc::Questions::ConfirmW2sController).to_path_helper
        end
      end

      private

      def illustration_path; end
    end
  end
end
