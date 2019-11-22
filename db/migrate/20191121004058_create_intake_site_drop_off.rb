class CreateIntakeSiteDropOff < ActiveRecord::Migration[5.2]
  def change
    create_table :intake_site_drop_offs do |t|
      t.string :intake_site, null: false
      t.string :name, null: false
      t.string :email
      t.string :phone_number
      t.string :pickup_method, null: false
      t.date :pickup_date
      t.string :additional_info
    end
  end
end
