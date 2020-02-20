class AddMultipleStatesToIntake < ActiveRecord::Migration[5.2]
  def change
    add_column :intakes, :multiple_states, :integer, default: 0, null: false
  end
end
