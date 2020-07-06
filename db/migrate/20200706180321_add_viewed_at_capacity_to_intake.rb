class AddViewedAtCapacityToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :viewed_at_capacity, :boolean, default: false
    add_column :intakes, :continued_at_capacity, :boolean, default: false
  end
end
