class AddExtensionPaymentsToNcAndId < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_nc_intakes, :extension_payments_amount, :decimal, precision: 12, scale: 2
    add_column :state_file_nc_intakes, :paid_extension_payments, :integer, default: 0, null: false
    add_column :state_file_id_intakes, :extension_payments_amount, :decimal, precision: 12, scale: 2
    add_column :state_file_id_intakes, :paid_extension_payments, :integer, default: 0, null: false
  end
end
