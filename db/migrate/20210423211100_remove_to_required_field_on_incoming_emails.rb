class RemoveToRequiredFieldOnIncomingEmails < ActiveRecord::Migration[6.0]
  def change
    change_column_null :incoming_emails, :to, true
  end
end
