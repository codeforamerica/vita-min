class AddSalesUseTaxColumnsToIdIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_id_intakes, :has_unpaid_sales_use_tax, :integer, default: 0, null: false
    add_column :state_file_id_intakes, :total_purchase_amount, :decimal, precision: 12, scale: 2
  end
end
