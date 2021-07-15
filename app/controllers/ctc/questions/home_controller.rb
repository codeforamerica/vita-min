module Ctc
  module Questions
    class HomeController < QuestionsController
      # TODO: Transition to Authenticated once we log in client
      include AnonymousIntakeConcern

      def edit
        @form = form_class.new
      end

      def update
        @form = form_class.new(form_params)
        render :edit and return unless @form.valid?

        send_mixpanel_event(event_name: "answered_question", data: form_attributes, subject: "home")
        redirect_to next_path
      end

      private

      def illustration_path; end

      def form_attributes
        return {} unless @form.class.scoped_attributes.key?(:home)

        @form.attributes_for(:home).except(*Rails.application.config.filter_parameters)
      end

      def next_path
        @form.lived_in_territory_or_at_foreign_address? ? questions_use_gyr_path : super
      end
    end
  end
end