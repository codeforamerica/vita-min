class CreateDriversLicense < ActiveRecord::Migration[6.1]
  def change
    create_table :drivers_licenses do |t|
      t.timestamps
      t.references :intake
      t.string :license_number, null: false
      t.string :state, null: false
      t.date :issue_date, null: false
      t.date :expiration_date, null: false
    end
    add_reference :intakes, :drivers_license
  end
end
