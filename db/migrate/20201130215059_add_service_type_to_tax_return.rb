class AddServiceTypeToTaxReturn < ActiveRecord::Migration[6.0]
  def change
    add_column :tax_returns, :service_type, :integer, default: 0
  end
end
