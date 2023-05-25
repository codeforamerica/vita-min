class AddErrorCodeToOutgoingMessageStatusAndOutgoingTextMessage < ActiveRecord::Migration[7.0]
  def change
    add_column :outgoing_message_statuses, :error_code, :string
    add_column :outgoing_text_messages, :error_code, :string
  end
end
