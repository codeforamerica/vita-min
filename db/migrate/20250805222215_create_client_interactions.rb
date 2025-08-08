class CreateClientInteractions < ActiveRecord::Migration[7.1]
  def change
    create_table :client_interactions do |t|
      t.references :client, null: false, foreign_key: true, index: true
      t.integer :interaction_type, default: 0, null: false
      t.timestamps
    end
  end
end
