class AddSpouseSignatureFieldsToTaxReturn < ActiveRecord::Migration[6.0]
  def change
    add_column :tax_returns, :spouse_signed_at, :datetime
    add_column :tax_returns, :spouse_signed_ip, :inet
    add_column :tax_returns, :spouse_signature, :string
    add_column :tax_returns, :primary_signature, :string
  end
end
