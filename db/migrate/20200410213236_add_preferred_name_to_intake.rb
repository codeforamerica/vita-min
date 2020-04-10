class AddPreferredNameToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :preferred_name, :string
    add_column :intakes, :state_of_residence, :string
  end
end
