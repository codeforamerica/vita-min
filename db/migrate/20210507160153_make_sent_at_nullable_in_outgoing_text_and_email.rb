class MakeSentAtNullableInOutgoingTextAndEmail < ActiveRecord::Migration[6.0]
  def change
    change_column_null :outgoing_emails, :sent_at, true
    change_column_null :outgoing_text_messages, :sent_at, true
  end
end
