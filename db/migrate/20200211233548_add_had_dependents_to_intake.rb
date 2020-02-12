class AddHadDependentsToIntake < ActiveRecord::Migration[5.2]
  def change
    add_column :intakes, :had_dependents, :integer, default: 0, null: false
  end
end
