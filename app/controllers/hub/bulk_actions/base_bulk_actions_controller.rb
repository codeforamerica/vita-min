module Hub
  module BulkActions
    class BaseBulkActionsController < ApplicationController
      include AccessControllable

      layout "admin"

      before_action :require_sign_in, :load_client_selection, :load_clients, :load_template_variables
      before_action :load_edit_form, only: :edit

      def edit; end

      private

      def load_edit_form
        @form = BulkActionForm.new(@client_selection)
      end

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
        @inaccessible_client_count = @client_selection.clients.where.not(id: @clients).size
        @locale_counts = @clients.locale_counts
        @no_contact_info_count = @clients.with_insufficient_contact_info.size
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
