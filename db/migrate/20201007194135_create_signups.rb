class CreateSignups < ActiveRecord::Migration[6.0]
  def change
    create_table :signups do |t|
      t.string :name
      t.string :zip_code
      t.string :email_address
      t.string :phone_number

      t.timestamps
    end
  end
end
