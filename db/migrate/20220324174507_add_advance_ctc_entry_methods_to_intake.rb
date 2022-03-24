class AddAdvanceCtcEntryMethodsToIntake < ActiveRecord::Migration[6.1]
  def change
    add_column :intakes, :advance_ctc_entry_method, :integer, default: 0, null: false
  end
end
