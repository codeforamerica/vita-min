class CreateAz322Contributions < ActiveRecord::Migration[7.1]
  def change
    create_table :az322_contributions do |t|
      t.date :date_of
      t.string :ctds_code
      t.string :school_name
      t.string :district_name
      t.integer :amount

      t.references :state_file_az_intake
      t.timestamps
    end
  end
end
