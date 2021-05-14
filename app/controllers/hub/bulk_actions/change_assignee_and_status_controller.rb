module Hub
  module BulkActions
    class ChangeAssigneeAndStatusController < BaseBulkActionsController
      include TaxReturnAssignableUsers

      before_action :load_current_tax_return_statuses, :load_assignable_users

      def update
        @form = BulkActionForm.new(@selection, update_params)

        return render :edit unless @form.valid?

        @status = @form.status == "no_change" ? nil : @form.status
        @assigned_user = @form.assigned_user_id == "no_change" ? nil : User.find(@form.assigned_user_id)

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

      def update_params
        params.require(:hub_bulk_action_form).permit(:note_body, :message_body_en, :message_body_es, :status, :assigned_user_id)
      end

      def load_current_tax_return_statuses
        @current_tr_statuses = @selection.tax_returns.pluck(:status).uniq
      end

      def load_assignable_users
        @assignable_users = @selection.tax_returns.map { |tr| assignable_users(tr.client, [current_user, tr.assigned_user])}.flatten.compact.uniq
      end

      def update_assignee_and_status!
        if @assigned_user || @status
          @selection.tax_returns.find_each do |tax_return|
            tax_return.update!(assigned_user: @assigned_user) unless @assigned_user.nil?
            tax_return.update!(status: @status) unless @status.nil?
          end
        end
      end

      def create_change_assignee_and_status_notifications!
        if @assigned_user || @status
          bulk_update = BulkTaxReturnAssigneeAndStatusUpdate.create!(tax_return_selection: @selection, assigned_user: @assigned_user, status: @status)
          UserNotification.create!(notifiable: bulk_update, user: current_user)
        end
      end
    end
  end
end
