class AddCtcFlagToClient < ActiveRecord::Migration[6.0]
  def change
    add_column :tax_returns, :is_ctc, :boolean, default: false
  end
end
