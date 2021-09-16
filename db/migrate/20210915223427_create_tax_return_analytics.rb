class CreateTaxReturnAnalytics < ActiveRecord::Migration[6.0]
  def change
    create_table :accepted_tax_return_analytics do |t|
      t.references :tax_return
      t.bigint :advance_ctc_amount_cents
      t.bigint :refund_amount_cents
      t.bigint :eip3_amount_cents
      t.timestamps
    end
  end
end
