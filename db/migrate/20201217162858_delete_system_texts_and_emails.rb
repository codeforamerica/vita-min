class DeleteSystemTextsAndEmails < ActiveRecord::Migration[6.0]
  def change
    drop_table :system_text_messages
    drop_table :system_emails
  end
end
