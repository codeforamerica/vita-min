class CreateCtcSignups < ActiveRecord::Migration[6.0]
  def change
    create_table :ctc_signups do |t|
      t.string :name
      t.string :email_address
      t.string :phone_number

      t.timestamps
    end
  end
end
