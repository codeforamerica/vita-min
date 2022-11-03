class CreateDataForBulkSignupMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :outgoing_message_statuses do |t|
      t.text :delivery_status
      t.text :message_id # TODO: can this be null: false?
      t.integer :message_type, null: false

      t.timestamps
    end

    create_table :bulk_signup_messages do |t|
      t.timestamps
    end

    create_table :signup_selections do |t|
      t.references :user, foreign_key: true
      t.integer :signup_type, null: false
      t.integer :id_array, array: true, default: []
      t.timestamps
    end
  end
end
