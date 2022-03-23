class IndexClientsOnLastOutgoingCommunicationAt < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :clients, :last_outgoing_communication_at, algorithm: :concurrently
  end
end
