class ChangeCoalitionNameToCaseInsensitive < ActiveRecord::Migration[7.0]
  def change
    safety_assured { change_column :coalitions, :name, :citext }
  end
end
