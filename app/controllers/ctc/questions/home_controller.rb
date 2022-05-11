module Ctc
  module Questions
    class HomeController < QuestionsController
      include Ctc::ResetToStartIfIntakeNotPersistedConcern

      private

      def illustration_path; end

      def next_path
        if @form.lived_in_territory_or_at_foreign_address?
          questions_use_gyr_path
        elsif @form.lived_in_puerto_rico?
          offboarding_cant_use_getctc_path
        else
          super
        end
      end

      def tracking_data
        @form.attributes_for(:misc)
      end
    end
  end
end
