class AddNeedsHelp2021ToIntake < ActiveRecord::Migration[6.1]
  def change
    add_column :intakes, :needs_help_2021, :integer, default: 0, null: false
  end
end
