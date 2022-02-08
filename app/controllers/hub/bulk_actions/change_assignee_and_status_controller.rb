module Hub
  module BulkActions
    class ChangeAssigneeAndStatusController < BaseBulkActionsController
      include TaxReturnAssignableUsers

      before_action :load_current_tax_return_statuses, :load_assignable_users

      def update
        @form = BulkActionForm.new(@selection, update_params)

        return render :edit unless @form.valid?

        ActiveRecord::Base.transaction do
          update_assignee_and_status!
          create_notes!
          create_change_assignee_and_status_notifications!
          create_outgoing_messages!
          create_user_notifications!
        end

        redirect_to hub_user_notifications_path
      end

      private

      def load_edit_form
        @form = BulkActionForm.new(@selection, {
          status: params.dig(:tax_return, :status),
          assigned_user_id: params.dig(:tax_return, :assigned_user_id)
        })
      end

      def update_params
        params.require(:hub_bulk_action_form).permit(:note_body, :message_body_en, :message_body_es, :status, :assigned_user_id)
      end

      def load_current_tax_return_statuses
        @current_tr_statuses = @selection.tax_returns.joins(:tax_return_transitions).where(tax_return_transitions: { most_recent: true }).map(&:current_state).uniq
      end

      def load_assignable_users
        @assignable_users = @selection.tax_returns.map { |tr| assignable_users(tr.client, [current_user, tr.assigned_user])}.flatten.compact.uniq
      end

      def update_assignee_and_status!
        @selection.tax_returns.find_each do |tax_return|
          TaxReturnAssignmentService.new(tax_return: tax_return, assigned_user: @form.assigned_user, assigned_by: current_user).assign! unless assignment_action == BulkTaxReturnUpdate::KEEP
          tax_return.transition_to!(@form.status) unless status_action == BulkTaxReturnUpdate::KEEP
        end
      end

      def assignment_action
        case @form.assigned_user_id
        when BulkTaxReturnUpdate::KEEP
          BulkTaxReturnUpdate::KEEP
        when BulkTaxReturnUpdate::REMOVE
          BulkTaxReturnUpdate::REMOVE
        else
          BulkTaxReturnUpdate::UPDATE
        end
      end

      def status_action
        case @form.status
        when BulkTaxReturnUpdate::KEEP
          BulkTaxReturnUpdate::KEEP
        else
          BulkTaxReturnUpdate::UPDATE
        end
      end

      def create_change_assignee_and_status_notifications!
        bulk_update = BulkTaxReturnUpdate.create!(
          tax_return_selection: @selection,
          assigned_user: @form.assigned_user,
          state: status_action == BulkTaxReturnUpdate::KEEP ? nil : @form.status,
          data: {
            assigned_user: assignment_action,
            status: status_action
          }
        )
        UserNotification.create!(notifiable: bulk_update, user: current_user)
      end
    end
  end
end