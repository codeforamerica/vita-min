class AddFilingStatusToTaxReturn < ActiveRecord::Migration[6.0]
  def change
    add_column :tax_returns, :filing_status, :integer
    add_column :tax_returns, :filing_status_note, :text
  end
end
