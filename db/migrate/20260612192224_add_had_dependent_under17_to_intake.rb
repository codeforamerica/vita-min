class AddHadDependentUnder17ToIntake < ActiveRecord::Migration[7.2]
  def change
    add_column :intakes, :had_qualifying_child_under_17, :integer, default: 0, null: false
  end
end
