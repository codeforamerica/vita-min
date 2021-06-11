class AddWillEfileToTaxReturn < ActiveRecord::Migration[6.0]
  def change
    add_column :tax_returns, :internal_efile, :boolean, default: false, null: false
  end
end
