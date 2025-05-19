class RemoveUnusedNeedsHelpColumns < ActiveRecord::Migration[7.1]
  def change
    # all of these values are "unfilled" (0) so we can remove them
    safety_assured do
      remove_column :intakes, :needs_help_2016
      remove_column :intakes, :needs_help_2022
      remove_column :intakes, :needs_help_2023
    end
  end
end
