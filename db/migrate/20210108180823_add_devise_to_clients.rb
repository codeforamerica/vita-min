class AddDeviseToClients < ActiveRecord::Migration[6.0]
  def change
    # trackable
    add_column :clients, :sign_in_count, :integer, default: 0, null: false
    add_column :clients, :current_sign_in_at, :datetime
    add_column :clients, :last_sign_in_at, :datetime
    add_column :clients, :current_sign_in_ip, :inet
    add_column :clients, :last_sign_in_ip, :inet

    # lockable
    add_column :clients, :failed_attempts, :integer, default: 0, null: false
    add_column :clients, :locked_at, :datetime
  end
end
