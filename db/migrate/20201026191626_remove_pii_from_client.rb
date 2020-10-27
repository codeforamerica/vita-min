class RemovePiiFromClient < ActiveRecord::Migration[6.0]
  def change
    remove_column :clients, :preferred_name, :string
    remove_column :clients, :email_address, :string
    remove_column :clients, :phone_number, :string
    remove_column :clients, :sms_phone_number, :string
  end
end
