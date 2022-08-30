module Hub
  module BulkActions
    class SendAMessageController < BaseBulkActionsController
      def update
        @form = BulkActionForm.new(@selection, update_params)

        return render :edit unless @form.valid?

        UserNotification.create!(notifiable: BulkActionNotification.new(task_type: task_type, tax_return_selection: @selection), user: current_user)
        BulkActionJob.perform_later(
          task: task_type,
          user: current_user,
          tax_return_selection: @selection,
          form_params: update_params
        )

        redirect_to hub_user_notifications_path
      end

      private

      def task_type
        :send_a_message
      end

      def update_params
        params.require(:hub_bulk_action_form).permit(:note_body, :message_body_en, :message_body_es)
      end
    end
  end
end
