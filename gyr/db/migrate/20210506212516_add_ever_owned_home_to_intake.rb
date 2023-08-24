class AddEverOwnedHomeToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :ever_owned_home, :integer, default: 0, null: false
  end
end
