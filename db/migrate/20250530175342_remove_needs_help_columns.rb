class RemoveNeedsHelpColumns < ActiveRecord::Migration[7.1]
  def up
    # ran a backfill rake task to move this data into the new needs_help_current_year, needs_help_previous_year_1 etc. columns before running this migration
    safety_assured do
      remove_column :intakes, :needs_help_2018
      remove_column :intakes, :needs_help_2019
      remove_column :intakes, :needs_help_2020
      remove_column :intakes, :needs_help_2021
    end
  end

  def down
    add_column :intakes, :needs_help_2018, :integer, default: 0, null: false
    add_column :intakes, :needs_help_2019, :integer, default: 0, null: false
    add_column :intakes, :needs_help_2020, :integer, default: 0, null: false
    add_column :intakes, :needs_help_2021, :integer, default: 0, null: false
  end
end