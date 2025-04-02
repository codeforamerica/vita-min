class AddNjExtensionPayments < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_nj_intakes, :extension_payments, :decimal, precision: 12, scale: 2
  end
end
