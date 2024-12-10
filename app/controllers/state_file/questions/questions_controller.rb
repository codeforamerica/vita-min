module StateFile
  module Questions
    class QuestionsController < ::Questions::QuestionsController
      include StateFile::StateFileIntakeConcern
      before_action :redirect_if_no_intake, :redirect_if_in_progress_intakes_ended

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

      def question_navigator
        @navigator ||= "Navigation::StateFile#{current_state_code.titleize}QuestionNavigation".constantize
      end

      helper_method :question_navigator

      def redirect_if_no_intake
        unless current_intake.present?
          flash[:notice] = I18n.t("devise.failure.timeout")
          redirect_to StateFile::StateFilePagesController.to_path_helper(action: :login_options)
        end
      end

      def redirect_if_in_progress_intakes_ended
        if app_time.after?(Rails.configuration.state_file_end_of_in_progress_intakes)
          if current_intake.efile_submissions.empty?
            redirect_to root_path
          else
            redirect_to StateFile::Questions::ReturnStatusController.to_path_helper(action: :edit)
          end
        end
      end

      def next_step
        form_navigation.next
      end

      def next_path
        step_for_next_path = next_step
        options = { action: step_for_next_path.navigation_actions.first }
        if step_for_next_path.resource_name.present? && step_for_next_path.resource_name == self.class.resource_name
          options[:id] = current_resource.id
        end
        step_for_next_path.to_path_helper(options)
      end

      def prev_step
        form_navigation.prev
      end

      def prev_action
        return unless self.class.navigation_actions.count > 1

        current_action = action_name.to_sym

        # look up action corresponding to the submitted form if we hit a validation error on submission and are re-rendering new/edit
        replacements = { update: :edit, create: :new }
        current_action = replacements[current_action] if replacements.key? current_action

        action_index = self.class.navigation_actions.index(current_action)

        case action_index
        when 0 then nil
        when 1.. then self.class.navigation_actions[action_index - 1]
        else self.class.navigation_actions[0]
        end
      end

      def prev_path
        if prev_action
          self.class.to_path_helper({ action: prev_action })
        else
          path_for_step(prev_step)
        end
      end

      def path_for_step(step)
        return unless step
        options = { action: step.navigation_actions.first }
        if step.resource_name
          options[:id] = step.model_for_show_check(self)&.id
        end
        step.to_path_helper(options)
      end

      # by default, most state file questions have no illustration
      def illustration_path; end

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
