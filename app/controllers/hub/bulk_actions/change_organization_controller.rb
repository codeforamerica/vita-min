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

        unassign_users_who_will_lose_access!
        update_clients_with_new_partner_and_note!
        enqueue_bulk_messaging_job

        redirect_to hub_client_selection_path(id: @client_selection)
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
        @current_vita_partner_names = VitaPartner.where(clients: @client_selection.clients).pluck(:name)
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
          client.update(vita_partner: @new_vita_partner)

          if @form.note_body.present?
            client.notes.create!(body: @form.note_body, user: current_user)
          end
        end
      end

      def enqueue_bulk_messaging_job
        if @form.message_body_en.present? || @form.message_body_es.present?
          BulkClientMessagingJob.perform_later(
            @client_selection,
            current_user,
            en: @form.message_body_en,
            es: @form.message_body_es,
            )
        end
      end
    end
  end
end
