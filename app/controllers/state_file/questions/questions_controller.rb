module StateFile
  module Questions
    class QuestionsController < ::Questions::QuestionsController
      skip_before_action :redirect_in_offseason
      skip_before_action :redirect_if_completed_intake_present
      before_action :redirect_if_no_intake
      helper_method :card_postscript

      # default layout for all state file questions
      layout "state_file/question"

      def ip_for_irs
        if Rails.env.test?
          "72.34.67.178"
        else
          request.remote_ip
        end
      end

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

      def redirect_if_no_intake
        if current_intake.present?
          # Assign the global id of the state_file_intake of the session to be that of the current_intake
          # This attempts to prevent the weird timeout issues we have been experiencing in the flow.
          # Where the session's intake does match the true current one and ends up timing out erroneously.
          session[:state_file_intake] = "gid://vita-min/#{current_intake.class}/#{current_intake.id}"
          # Sign out from previous intake if they differ from current_intake
          # TODO
        else
          begin
            visitor_id = cookies['visitor_id']
            raise "The session for visitor with id:#{visitor_id} has expired"
          rescue => e
            Sentry.capture_exception(e)
          end
          flash[:notice] = 'Your session expired. Please sign in again to continue.'
          redirect_to root_path
        end
      end

      def next_step
        form_navigation.next
      end

      def next_path
        step_for_next_path = next_step
        options = { us_state: params[:us_state], action: step_for_next_path.navigation_actions.first }
        if step_for_next_path.resource_name.present? && step_for_next_path.resource_name == self.class.resource_name
          options[:id] = current_resource.id
        end
        step_for_next_path.to_path_helper(options)
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

      def card_postscript; end

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
