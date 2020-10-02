class MakeEmailAndPhoneNumberNotNullableInOutgoingTextAndEmail < ActiveRecord::Migration[6.0]
  def change
    change_column_null :outgoing_emails, :to, false
    change_column_null :outgoing_text_messages, :to_phone_number, false
  end
end
