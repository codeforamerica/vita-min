class ChangeAllEmailsToCaseInsensitiveText < ActiveRecord::Migration[6.0]
  def up
    change_column :signups, :email_address, :citext
    change_column :users, :email, :citext
    change_column :outgoing_emails, :to, :citext
    change_column :incoming_emails, :from, :citext
    change_column :incoming_emails, :to, :citext
  end

  def down
    change_column :signups, :email_address, :string
    change_column :users, :email, :string
    change_column :outgoing_emails, :to, :string
    change_column :incoming_emails, :from, :string
    change_column :incoming_emails, :to, :string
  end
end
