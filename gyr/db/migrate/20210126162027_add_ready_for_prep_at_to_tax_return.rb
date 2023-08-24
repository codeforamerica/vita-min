class AddReadyForPrepAtToTaxReturn < ActiveRecord::Migration[6.0]
  def change
    add_column :tax_returns, :ready_for_prep_at, :datetime
  end
end
