class AddMailingAddressToIntake < ActiveRecord::Migration[5.2]
  def change
    change_table :intakes do |t|
      t.string :street_address
      t.string :city
      t.string :state
      t.string :zip_code
    end
  end
end
