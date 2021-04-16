class CreateBulkClientMessageOutgoingTextMessage < ActiveRecord::Migration[6.0]
  def change
    create_table :bulk_client_message_outgoing_text_messages do |t|
      t.timestamps
      t.references :bulk_client_message, null: false, foreign_key: true, index: { name: :index_bcmotm_on_bulk_client_message_id }
      t.references :outgoing_text_message, null: false, foreign_key: true, index: { name: :index_bcmotm_on_outgoing_text_message_id }
    end
  end
end
