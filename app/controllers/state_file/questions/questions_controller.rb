module StateFile
  module Questions
    class QuestionsController < ::Questions::QuestionsController
      include StateFile::StateFileControllerConcern
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

      def show_progress?
        question_navigator.controllers.include?(self.class)
      end

      private

      def current_intake
        state_code = question_navigator.intake_class::STATE_CODE
        send("current_state_file_#{state_code}_intake")
      end

      def question_navigator
        @navigator ||= "Navigation::StateFile#{state_code.titleize}QuestionNavigation".constantize
      end
      helper_method :question_navigator

      def state_code
        state_code_ = params[:us_state].downcase
        unless StateFileBaseIntake::STATE_CODES.include?(state_code_)
          raise StandardError, state_code_
        end
        state_code_
      end

      def redirect_if_no_intake
        unless current_intake.present?
          flash[:notice] = 'Your session expired. Please sign in again to continue.'
          redirect_to StateFile::StateFilePagesController.to_path_helper(action: :login_options, us_state: state_code)
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
        path_for_step(form_navigation.prev)
      end

      def path_for_step(step)
        return unless step
        options = { us_state: params[:us_state], action: step.navigation_actions.first }
        if step.resource_name
          options[:id] = step.model_for_show_check(self)&.id
        end
        step.to_path_helper(options)
      end

      # by default, most state file questions have no illustration
      def illustration_path; end

      def card_postscript; end

      def update_for_device_id_collection(efile_device_info)
        @form = initialized_update_form
        if form_params["device_id"].blank? && efile_device_info&.device_id.blank?
          flash[:alert] = I18n.t("general.enable_javascript")
          redirect_to render: :edit
        else
          flash.clear
          method(:update).super_method.call
        end
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
