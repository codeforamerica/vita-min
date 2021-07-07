class AddMiddleInitialToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :primary_middle_initial, :string
  end
end
