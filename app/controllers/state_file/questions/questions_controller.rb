module StateFile
  module Questions
    class QuestionsController < ::Questions::QuestionsController
      include StateFile::StateFileIntakeConcern
      include StateFile::FystSunsetRedirectConcern
      before_action :redirect_if_no_intake, :redirect_if_in_progress_intakes_ended, :redirect_if_df_data_required

      # default layout for all state file questions
      layout "state_file/question"

      def ip_for_irs
        if Rails.env.test?
          "72.34.67.178"
        else
          request.remote_ip
        end
      end

      def review_controller
        StateFile::StateInformationService.review_controller_class(current_state_code)
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

      def redirect_if_df_data_required
        return if current_state_code == "nj"
        return unless question_navigator&.get_section(self.class)&.df_data_required

        unless current_intake.df_data_import_succeeded_at.present?
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
        next_page_info = next_step
        return unless next_page_info&.dig(:controller)
        next_page_controller = next_page_info[:controller]

        options = { action: next_page_controller.navigation_actions.first }
        options[:item_index] = next_page_info[:item_index] if next_page_info&.key? :item_index

        if next_page_controller.resource_name && next_page_controller.resource_name == self.class.resource_name
          options[:id] = current_resource.id
        end
        if next_page_info.key? :params
          options.merge!(next_page_info[:params])
        end

        next_page_controller.to_path_helper(options)
      end

      def prev_step
        form_navigation.prev
      end

      def prev_action
        return unless self.class.navigation_actions.count > 1

        if self.class.navigation_actions.first != action_name.to_sym
          self.class.navigation_actions.first
        end
      end

      def prev_path
        if prev_action
          self.class.to_path_helper({ action: prev_action })
        else
          prev_page_info = prev_step
          return unless prev_page_info&.dig(:controller)
          prev_page_controller = prev_page_info[:controller]

          options = { action: prev_page_controller.navigation_actions.first }
          options[:item_index] = prev_page_info[:item_index] if prev_page_info&.key? :item_index
          if prev_page_controller.resource_name
            options[:id] = prev_page_controller.model_for_show_check(self)&.id
          end
          if prev_page_info.key? :params
            options.merge!(prev_page_info[:params])
          end
          prev_page_controller.to_path_helper(options)
        end
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
