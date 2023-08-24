class AddDefaultToTaxReturnCurrentState < ActiveRecord::Migration[7.0]
  def change
    change_column_default :tax_returns, :current_state, from: nil, to: "intake_before_consent"
  end
end
