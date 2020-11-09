class AddStatusToTaxReturn < ActiveRecord::Migration[6.0]
  def change
    add_column :tax_returns, :status, :integer
  end
end
