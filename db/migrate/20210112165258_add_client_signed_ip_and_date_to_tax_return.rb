class AddClientSignedIpAndDateToTaxReturn < ActiveRecord::Migration[6.0]
  def change
    add_column :tax_returns, :primary_signed_at, :datetime
    add_column :tax_returns, :primary_signed_ip, :inet
  end
end
