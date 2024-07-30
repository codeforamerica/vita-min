class AddFieldsToAz322Contributions < ActiveRecord::Migration[7.1]
  def change
    add_column :az322_contributions, :made_contribution, :integer
  end
end
