class AddVinNumberToIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :intakes, :vin_number, :string
  end
end
