module Hub
  module BulkActions
    class ChangeOrganizationController < BaseBulkActionsController
      before_action :load_vita_partners
      before_action :load_current_vita_partner_names

      def update
        @form = BulkActionForm.new(@client_selection, update_params)

        return render :edit unless @form.valid?

        @new_vita_partner = @vita_partners.find(@form.vita_partner_id)

        ActiveRecord::Base.transaction do
          unassign_users_who_will_lose_access!
          update_clients_with_new_partner!
          create_notes!
          create_change_org_notifications!
          create_outgoing_messages!
          create_user_notifications!
        end

        redirect_to hub_user_notifications_path
      end

      private

      def update_params
        params.require(:hub_bulk_action_form).permit(:vita_partner_id, :note_body, :message_body_en, :message_body_es)
      end

      def load_current_vita_partner_names
        @current_vita_partner_names = VitaPartner.where(clients: @client_selection.clients).pluck(:name).uniq.sort
      end

      def create_change_org_notifications!
        if @new_vita_partner.present?
          bulk_update = BulkClientOrganizationUpdate.create!(client_selection: @client_selection, vita_partner: @new_vita_partner)
          UserNotification.create!(notifiable: bulk_update, user: current_user)
        end
      end

      def unassign_users_who_will_lose_access!
        TaxReturn.where(client: @clients).where.not(assigned_user: nil).find_each do |tax_return|
          assigned_user_retains_access = tax_return.assigned_user.accessible_vita_partners.include?(@new_vita_partner)
          tax_return.update!(assigned_user: nil) unless assigned_user_retains_access
        end
      end

      def update_clients_with_new_partner!
        @clients.find_each do |client|
          client.update!(vita_partner: @new_vita_partner)
        end
      end
    end
  end
end
