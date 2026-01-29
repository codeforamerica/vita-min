class AddPreferenceForHelpForIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :intakes, :service_preference, :integer, default: 0, null: false
  end
end
