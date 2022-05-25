class AddNewColumnsToAcceptedTaxReturnAnalytics < ActiveRecord::Migration[7.0]
  def change
    add_column :accepted_tax_return_analytics, :tax_return_year, :integer
    add_column :accepted_tax_return_analytics, :outstanding_ctc_amount_cents, :bigint
    add_column :accepted_tax_return_analytics, :ctc_amount_cents, :bigint
    add_column :accepted_tax_return_analytics, :eip3_amount_received_cents, :bigint
    add_column :accepted_tax_return_analytics, :outstanding_eip3_amount_cents, :bigint
    add_column :accepted_tax_return_analytics, :total_refund_amount_cents, :bigint
    safety_assured { rename_column :accepted_tax_return_analytics, :refund_amount_cents, :eip1_and_eip2_amount_cents }
  end
end
