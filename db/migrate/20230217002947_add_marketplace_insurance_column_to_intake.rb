class AddMarketplaceInsuranceColumnToIntake < ActiveRecord::Migration[7.0]
  def change
    add_column :intakes, :bought_marketplace_health_insurance, :integer, default: 0, null: false
  end
end
