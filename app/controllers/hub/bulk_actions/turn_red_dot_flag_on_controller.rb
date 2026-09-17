module Hub
  module BulkActions
    class TurnRedDotFlagOnController < BaseBulkActionsController
      def update
        UserNotification.create!(
          notifiable: BulkActionNotification.new(task_type: task_type, tax_return_selection: @tax_return_selection),
          user: current_user
        )

        BulkActionJob.perform_later(
          task: task_type,
          user: current_user,
          tax_return_selection: @tax_return_selection,
          form_params: {}
        )

        redirect_to hub_user_notifications_path
      end

      private

      def task_type
        :turn_red_dot_flag_on
      end
    end
  end
end