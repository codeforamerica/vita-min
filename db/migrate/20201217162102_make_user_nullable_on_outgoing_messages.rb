class MakeUserNullableOnOutgoingMessages < ActiveRecord::Migration[6.0]
  def change
    change_column :outgoing_emails, :user_id, :bigint, null: true
    change_column :outgoing_text_messages, :user_id, :bigint, null: true
  end
end
