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
        next_step = form_navigation.next
        options = {}
        if next_step.resource_name.present? && next_step.resource_name == self.class.resource_name
          options[:id] = current_resource.id
        end
        next_step.to_path_helper(options)
      end

      def prev_path
        prev_step = form_navigation.prev
        return unless prev_step

        options = {}
        if prev_step.resource_name
          options[:id] = prev_step.model_for_show_check(self)&.id
        end
        prev_step.to_path_helper(options)
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
