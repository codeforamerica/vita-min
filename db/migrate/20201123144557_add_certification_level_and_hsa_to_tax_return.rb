class AddCertificationLevelAndHsaToTaxReturn < ActiveRecord::Migration[6.0]
  def change
    add_column :tax_returns, :certification_level, :integer
    add_column :tax_returns, :is_hsa, :boolean
  end
end
