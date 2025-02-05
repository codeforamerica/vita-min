class AddNeedsHelp2023ToIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :intakes, :needs_help_2023, :integer, default: 0, null: false
  end
end
