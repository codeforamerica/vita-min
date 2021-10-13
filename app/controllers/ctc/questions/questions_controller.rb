module Ctc
  module Questions
    class QuestionsController < ::Questions::QuestionsController
      helper_method :wrapping_layout
      skip_before_action :redirect_in_offseason

      private

      def wrapping_layout
        "ctc"
      end

      def progress_calculator
        CtcIntakeProgressCalculator
      end

      def question_navigator
        CtcQuestionNavigation
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
