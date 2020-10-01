class AddToPhoneNumberToOutgoingTextMessage < ActiveRecord::Migration[6.0]
  def change
    add_column :outgoing_text_messages, :to_phone_number, :string, null: true
  end
end
