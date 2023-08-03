class CreateStateFileNyIntakes < ActiveRecord::Migration[7.0]
  def change
    create_table :state_file_ny_intakes do |t|
      t.string :first_name

      t.timestamps
    end
  end
end
