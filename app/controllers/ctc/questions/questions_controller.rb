module Ctc
  module Questions
    class QuestionsController < ::Questions::QuestionsController
      helper_method :wrapping_layout
      before_action :redirect_if_completed_intake_present
      before_action :redirect_if_read_only
      skip_before_action :redirect_in_offseason

      private

      def redirect_if_completed_intake_present
        if current_intake && current_intake.completed_at.present?
          redirect_to ctc_completed_intake_path
        end
      end

      def redirect_if_read_only
        return if open_for_ctc_read_write?

        redirect_back(fallback_location: Ctc::Portal::PortalController.to_path_helper(action: :home))
      end

      def wrapping_layout
        "ctc"
      end

      def progress_calculator
        CtcIntakeProgressCalculator
      end

      def question_navigator
        Navigation::CtcQuestionNavigation
      end

      def parent_class
        Intake::CtcIntake
      end

      def next_path
        next_page_info = form_navigation.next
        return unless next_page_info&.dig(:controller)
        next_page_controller = next_page_info[:controller]

        options = {}
        if next_page_controller.resource_name && next_page_controller.resource_name == self.class.resource_name
          options[:id] = current_resource.id
        end
        next_page_controller.to_path_helper(options)
      end

      def prev_path
        prev_page_info = form_navigation.prev
        return unless prev_page_info&.dig(:controller)
        prev_page_controller = prev_page_info[:controller]

        options = {}
        if prev_page_controller.resource_name
          options[:id] = prev_page_controller.model_for_show_check(self)&.id
        end
        prev_page_controller.to_path_helper(options)
      end

      class << self
        def resource_name
          nil
        end

        def form_key
          "ctc/" + controller_name + "_form"
        end
      end
    end
  end
end
