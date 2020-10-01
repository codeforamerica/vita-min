class AddToToOutgoingEmail < ActiveRecord::Migration[6.0]
  def change
    add_column :outgoing_emails, :to, :string, null: true
  end
end
