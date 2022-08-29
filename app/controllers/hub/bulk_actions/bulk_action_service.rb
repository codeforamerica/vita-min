module Hub
  module BulkActions
    class BulkActionService
      def change_organization
        ActiveRecord::Base.transaction do
          UpdateClientVitaPartnerService.new(clients: @clients, vita_partner_id: @form.vita_partner_id, change_initiated_by: current_user).update!
          create_notes!
          create_change_org_notifications!
          create_outgoing_messages!
        end
      end
    end
  end
end
