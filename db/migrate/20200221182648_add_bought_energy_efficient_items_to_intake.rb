class AddBoughtEnergyEfficientItemsToIntake < ActiveRecord::Migration[5.2]
  def change
    add_column :intakes, :bought_energy_efficient_items, :integer
  end
end
