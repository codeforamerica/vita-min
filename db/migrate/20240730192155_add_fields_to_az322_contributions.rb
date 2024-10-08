class AddFieldsToAz322Contributions < ActiveRecord::Migration[7.1]
  def change
    add_column :az322_contributions, :made_contribution, :integer, default: 0, null: false
  end
end
