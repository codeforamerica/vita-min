class AddNewVehiclePurchasedToIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :intakes, :new_vehicle_purchased, :integer, default: 0
  end
end
