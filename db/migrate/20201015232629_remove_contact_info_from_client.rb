class RemoveContactInfoFromClient < ActiveRecord::Migration[6.0]
  def change
    remove_column :clients, :preferred_name
    remove_column :clients, :phone_number
    remove_column :clients, :email_address
    remove_column :clients, :sms_phone_number
    remove_reference :clients, :vita_partner
  end
end
