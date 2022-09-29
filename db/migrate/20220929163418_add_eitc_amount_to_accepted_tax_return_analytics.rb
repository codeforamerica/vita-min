class AddEitcAmountToAcceptedTaxReturnAnalytics < ActiveRecord::Migration[7.0]
  def change
    add_column :accepted_tax_return_analytics, :eitc_amount_cents, :bigint
  end
end
