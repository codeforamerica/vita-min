module StateFile
  module Questions
    class QuestionsController < ::Questions::QuestionsController
      skip_before_action :redirect_in_offseason
      skip_before_action :redirect_if_completed_intake_present

      # default layout for all state file questions
      layout "state_file/question"

      private

      def current_intake
        intake = GlobalID.find(session[:state_file_intake])
        return nil if intake && !intake.is_a?(question_navigator.intake_class)
        intake
      end

      def question_navigator
        case params[:us_state]
        when 'az'
          Navigation::StateFileAzQuestionNavigation
        when 'ny'
          Navigation::StateFileNyQuestionNavigation
        end
      end

      def next_path
        next_step = form_navigation.next
        unless params[:review].nil?
          case params[:us_state]
          when 'az'
            next_step = StateFile::Questions::AzReviewController
          when 'ny'
            next_step = StateFile::Questions::NyReviewController
          end
        end
        options = { us_state: params[:us_state], action: next_step.navigation_actions.first }
        if next_step.resource_name.present? && next_step.resource_name == self.class.resource_name
          options[:id] = current_resource.id
        end
        next_step.to_path_helper(options)
      end

      def prev_path
        prev_step = form_navigation.prev
        return unless prev_step

        options = { us_state: params[:us_state], action: prev_step.navigation_actions.first }
        if prev_step.resource_name
          options[:id] = prev_step.model_for_show_check(self)&.id
        end
        prev_step.to_path_helper(options)
      end

      # by default, most state file questions have no illustration
      def illustration_path; end

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
