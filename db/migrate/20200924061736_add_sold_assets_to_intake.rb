class AddSoldAssetsToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :sold_assets, :integer, default: 0, null: false
  end
end
