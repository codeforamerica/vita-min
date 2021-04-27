module Hub
  module BulkActions
    class SendAMessageController < BaseBulkActionsController
      def update
        @form = BulkActionForm.new(@client_selection, update_params)

        return render :edit unless @form.valid?

        ActiveRecord::Base.transaction do
          create_outgoing_messages!
          create_user_notifications!
        end

        redirect_to hub_user_notifications_path
      end
    end
  end
end
