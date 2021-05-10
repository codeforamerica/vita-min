class SetIncomingPortalMessageClientAndOutboundCallUserAsNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :incoming_portal_messages, :client_id, :false
    change_column_null :outbound_calls, :user_id, :false
  end
end
