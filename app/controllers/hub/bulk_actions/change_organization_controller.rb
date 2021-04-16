module Hub
  module BulkActions
    class ChangeOrganizationController < ApplicationController
      include AccessControllable

      layout "admin"

      before_action :require_sign_in, :load_vita_partners, :load_client_selection, :load_clients, :load_template_variables

      def edit
        @form = BulkActionForm.new(@client_selection)
      end

      def update
        @form = BulkActionForm.new(@client_selection, update_params)

        return render :edit unless @form.valid?

        @new_vita_partner = @vita_partners.find(@form.vita_partner_id)

        ActiveRecord::Base.transaction do
          unassign_users_who_will_lose_access!
          update_clients_with_new_partner_and_note!
          create_outgoing_messages!
          create_user_notifications!
        end

        redirect_to hub_user_notifications_path
      end

      private

      def update_params
        params.require(:hub_bulk_action_form).permit(:vita_partner_id, :note_body, :message_body_en, :message_body_es)
      end

      def load_clients
        @clients = @client_selection.clients.accessible_by(current_ability)
      end

      def load_client_selection
        @client_selection = ClientSelection.find(params[:client_selection_id])
      end

      def load_template_variables
        @current_vita_partner_names = VitaPartner.where(clients: @client_selection.clients).pluck(:name).uniq.sort
        @inaccessible_client_count = @client_selection.clients.where.not(id: @clients).size
        @locale_count = @clients.locale_counts
        @no_contact_info_count = @clients.with_insufficient_contact_info.size
      end

      def unassign_users_who_will_lose_access!
        TaxReturn.where(client: @clients).where.not(assigned_user: nil).find_each do |tax_return|
          assigned_user_retains_access = tax_return.assigned_user.accessible_vita_partners.include?(@new_vita_partner)
          tax_return.update!(assigned_user: nil) unless assigned_user_retains_access
        end
      end

      def update_clients_with_new_partner_and_note!
        @clients.find_each do |client|
          client.update!(vita_partner: @new_vita_partner)

          if @form.note_body.present?
            client.notes.create!(body: @form.note_body, user: current_user)
          end
        end
      end

      def create_outgoing_messages!
        if @form.message_body_en.present? || @form.message_body_es.present?
          @bulk_client_message = ClientMessagingService.send_bulk_message(
            @client_selection,
            current_user,
            en: @form.message_body_en,
            es: @form.message_body_es,
          )
        end
      end

      def create_user_notifications!
        bulk_update = BulkClientOrganizationUpdate.create!(client_selection: @client_selection, vita_partner: @new_vita_partner)
        UserNotification.create!(notifiable: bulk_update, user: current_user)

        if @form.note_body.present?
          bulk_note = BulkClientNote.create!(client_selection: @client_selection)
          UserNotification.create!(notifiable: bulk_note, user: current_user)
        end

        if @bulk_client_message.present?
          UserNotification.create!(notifiable: @bulk_client_message, user: current_user)
        end
      end
    end
  end
end
