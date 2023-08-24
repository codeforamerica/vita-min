class AddEipEntryMethodsToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :eip1_entry_method, :integer, default: 0, null: false
    add_column :intakes, :eip2_entry_method, :integer, default: 0, null: false
  end
end
