class AddNeedsHelp2020ToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :needs_help_2020, :integer, default: 0, null: false
  end
end
