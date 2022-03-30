class AddEip3EntryMethodToIntake < ActiveRecord::Migration[6.1]
  def change
    add_column :intakes, :eip3_entry_method, :integer, default: 0, null: false
  end
end
