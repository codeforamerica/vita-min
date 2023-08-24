class IndexYearOnTaxReturn < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :tax_returns, :year, algorithm: :concurrently
  end
end
