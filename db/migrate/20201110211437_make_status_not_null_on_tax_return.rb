class MakeStatusNotNullOnTaxReturn < ActiveRecord::Migration[6.0]
  def change
    # status 100 is intake_before_consent
    change_column_default :tax_returns, :status, 100
    change_column_null :tax_returns, :status, false, 100
  end
end
