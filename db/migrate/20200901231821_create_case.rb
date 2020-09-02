class CreateCase < ActiveRecord::Migration[6.0]
  def change
    create_table :cases do |t|
      t.string :preferred_name, null: false
      t.string :email_address, null: false
      t.string :phone_number, null: false
      t.string :sms_phone_number
      t.timestamps
    end
  end
end
