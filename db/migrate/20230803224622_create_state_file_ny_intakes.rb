class CreateStateFileNyIntakes < ActiveRecord::Migration[7.0]
  def change
    create_table :state_file_ny_intakes do |t|
      t.string :primary_first_name
      t.string :primary_last_name

      t.timestamps
    end
  end
end
