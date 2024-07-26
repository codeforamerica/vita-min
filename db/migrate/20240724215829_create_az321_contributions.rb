class CreateAz321Contributions < ActiveRecord::Migration[7.1]
  def change
    create_table :az321_contributions do |t|
      t.date :date_of_contribution
      t.string :charity_code
      t.string :charity_name
      t.decimal :amount, precision: 12, scale: 2

      t.references :state_file_az_intake
      t.timestamps
    end
  end
end
