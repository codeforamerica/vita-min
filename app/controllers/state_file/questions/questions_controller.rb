module StateFile
  module Questions
    class QuestionsController < ::Questions::QuestionsController
      skip_before_action :redirect_if_completed_intake_present

      private

      def question_navigator
        if params[:us_state] == 'az'
          Navigation::StateFileAzQuestionNavigation
        elsif params[:us_state] == 'ny'
          Navigation::StateFileNyQuestionNavigation
        end
      end

      def next_path
        next_step = form_navigation.next
        options = { us_state: params[:us_state] }
        if next_step.resource_name.present? && next_step.resource_name == self.class.resource_name
          options[:id] = current_resource.id
        end
        next_step.to_path_helper(options)
      end

      def prev_path
        prev_step = form_navigation.prev
        return unless prev_step

        options = { us_state: params[:us_state] }
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
          "state_file/" + controller_name + "_form"
        end
      end
    end
  end
end
