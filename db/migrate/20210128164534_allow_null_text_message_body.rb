class AllowNullTextMessageBody < ActiveRecord::Migration[6.0]
  def change
    change_column_null :incoming_text_messages, :body, true
  end
end
