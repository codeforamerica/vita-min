module Hub
  module BulkActions
    class ChangeOrganizationController < BaseBulkActionsController
      before_action :load_vita_partners
      before_action :load_current_vita_partner_names

      def update
        @form = BulkActionForm.new(@selection, update_params)

        return render :edit unless @form.valid?

        @new_vita_partner = @vita_partners.find(@form.vita_partner_id)

        bulk_action_notification = UserNotification.create!(notifiable_type: "BulkClientOrganizationUpdate", user: current_user)
        BulkActionJob.new(
          task: :change_organization,
          user: current_user,
          tax_return_selection: @selection,
          form_params: update_params,
          bulk_action_notification: bulk_action_notification,
        ).perform_now

        redirect_to hub_user_notifications_path
      end

      private

      def update_params
        params.require(:hub_bulk_action_form).permit(:vita_partner_id, :note_body, :message_body_en, :message_body_es)
      end

      def load_current_vita_partner_names
        @current_vita_partner_names = VitaPartner.where(clients: @selection.clients).pluck(:name).uniq.sort
      end

      def create_change_org_notifications!
        if @new_vita_partner.present?
          bulk_update = BulkClientOrganizationUpdate.create!(tax_return_selection: @selection, vita_partner: @new_vita_partner)
          UserNotification.create!(notifiable: bulk_update, user: current_user)
        end
      end
    end
  end
end
