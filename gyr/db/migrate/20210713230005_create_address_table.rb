class CreateAddressTable < ActiveRecord::Migration[6.0]
  def change
    create_table :addresses do |t|
      t.string :street_address
      t.string :street_address2
      t.string :city
      t.string :state
      t.string :zip_code
      t.references :record, polymorphic: true, index: false
      t.timestamps
    end
  end
end
