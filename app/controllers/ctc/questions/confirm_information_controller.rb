module Ctc
  module Questions
    class ConfirmInformationController < QuestionsController
      include AuthenticatedCtcClientConcern

      def edit
        first_verified_address_set = ActiveRecord::Base.connection.execute('SELECT MIN(usps_address_verified_at) FROM intakes').first['min']
        intake_created_after_verification_started = first_verified_address_set && current_intake.created_at > first_verified_address_set
        @submit_disabled = intake_created_after_verification_started &&
          current_intake.usps_address_verified_at.blank? &&
          current_intake.usps_address_late_verification_attempts == 0
        super
      end

      layout "intake"
      
      def illustration_path
        "successfully-submitted.svg"
      end
    end
  end
end
