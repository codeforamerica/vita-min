class CreateDataForBulkSignupMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :outgoing_message_statuses do |t|
      t.text :delivery_status
      t.text :message_id # TODO: can this be null: false?
      t.integer :message_type, null: false
      t.references :parent, polymorphic: true, null: false
      t.timestamps
    end

    create_table :signup_selections do |t|
      t.references :user, foreign_key: true
      t.integer :signup_type, null: false
      t.integer :id_array, array: true, null: false
      t.text :filename, null: false
      t.timestamps
    end

    create_table :bulk_signup_messages do |t|
      t.references :user, foreign_key: true, null: false
      t.references :signup_selection, foreign_key: true, null: false
      t.integer :message_type, null: false
      t.text :subject
      t.text :message, null: false
      t.timestamps
    end

    create_table :bulk_signup_message_outgoing_message_statuses do |t|
      t.references :bulk_signup_message, foreign_key: true, null: false, index: { name: :index_bsmoms_on_bulk_signup_messages_id }
      t.references :outgoing_message_status, foreign_key: true, null: false, index: { name: :index_bsmoms_on_outgoing_message_statuses_id }
    end
  end
end
