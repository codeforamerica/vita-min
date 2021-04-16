class CreateBulkClientMessageOutgoingEmail < ActiveRecord::Migration[6.0]
  def change
    create_table :bulk_client_message_outgoing_emails do |t|
      t.timestamps
      t.references :bulk_client_message, null: false, foreign_key: true, index: { name: :index_bcmoe_on_bulk_client_message_id }
      t.references :outgoing_email, null: false, foreign_key: true, index: { name: :index_bcmoe_on_outgoing_email_id }
    end
  end
end
