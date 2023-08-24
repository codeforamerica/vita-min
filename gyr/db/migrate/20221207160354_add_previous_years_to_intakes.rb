class AddPreviousYearsToIntakes < ActiveRecord::Migration[7.0]
  def change
    add_column :intakes, :needs_help_previous_year_3, :integer, default: 0, null: false
    add_column :intakes, :needs_help_previous_year_2, :integer, default: 0, null: false
    add_column :intakes, :needs_help_previous_year_1, :integer, default: 0, null: false
    add_column :intakes, :needs_help_current_year, :integer, default: 0, null: false
  end
end
