class AddNjExtensionPayments < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_nj_intakes, :extension_payments, :integer, default: 0, null: false
  end
end
