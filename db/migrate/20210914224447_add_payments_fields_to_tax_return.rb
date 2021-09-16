class AddPaymentsFieldsToTaxReturn < ActiveRecord::Migration[6.0]
  def change
    add_column :tax_returns, :refund_amount_cents, :bigint
    add_column :tax_returns, :ctc_amount_cents, :bigint
    add_column :tax_returns, :eip3_amount_cents, :bigint
  end
end
