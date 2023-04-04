module Hub
  module BulkActions
    class ChangeAssigneeAndStatusController < BaseBulkActionsController
      include TaxReturnAssignableUsers

      before_action :load_current_tax_return_statuses, :load_assignable_users

      def update
        @form = BulkActionForm.new(@tax_return_selection, update_params)

        return render :edit unless @form.valid?

        UserNotification.create!(notifiable: BulkActionNotification.new(task_type: task_type, tax_return_selection: @tax_return_selection), user: current_user)
        BulkActionJob.perform_later(
          task: task_type,
          user: current_user,
          tax_return_selection: @tax_return_selection,
          form_params: update_params
        )

        redirect_to hub_user_notifications_path
      end

      private

      def task_type
        :change_assignee_and_status
      end

      def load_edit_form
        @form = BulkActionForm.new(@tax_return_selection, {
          status: params.dig(:tax_return, :status),
          assigned_user_id: params.dig(:tax_return, :assigned_user_id)
        })
      end

      def update_params
        params.require(:hub_bulk_action_form).permit(:note_body, :message_body_en, :message_body_es, :status, :assigned_user_id)
      end

      def load_current_tax_return_statuses
        @current_tr_statuses = @tax_return_selection.tax_returns.joins(:tax_return_transitions).where(tax_return_transitions: { most_recent: true }).map(&:current_state).uniq
      end

      def load_assignable_users
        @assignable_users = @tax_return_selection.tax_returns.map { |tr| assignable_users(tr.client, [current_user, tr.assigned_user])}.flatten.compact.uniq
      end
    end
  end
end
