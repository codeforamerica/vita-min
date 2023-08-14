class CreateStateFileAzIntake < ActiveRecord::Migration[7.0]
  def change
    create_table :state_file_az_intakes do |t|
      t.string :primary_first_name
      t.string :primary_last_name
      t.integer :tax_return_year
      t.string :street_address
      t.string :city
      t.string :zip_code
      t.string :ssn
      t.date :birth_date
      t.string :current_step
      t.string :visitor_id

      t.timestamps
    end
  end
end
