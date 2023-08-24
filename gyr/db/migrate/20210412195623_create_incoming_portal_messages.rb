class CreateIncomingPortalMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :incoming_portal_messages do |t|
      t.references :client
      t.text :body
      t.timestamps
    end
  end
end
