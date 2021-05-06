module Hub
  module BulkActions
    class SendAMessageController < BaseBulkActionsController
      def update
        @form = BulkActionForm.new(@selection, update_params)

        return render :edit unless @form.valid?

        ActiveRecord::Base.transaction do
          create_notes!
          create_outgoing_messages!
          create_user_notifications!
        end

        redirect_to hub_user_notifications_path
      end

      private

      def update_params
        params.require(:hub_bulk_action_form).permit(:note_body, :message_body_en, :message_body_es)
      end
    end
  end
end
