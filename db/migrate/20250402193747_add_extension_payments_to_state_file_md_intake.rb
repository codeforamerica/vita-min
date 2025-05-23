class AddExtensionPaymentsToStateFileMdIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_md_intakes, :extension_payments_amount, :decimal, precision: 12, scale: 2
    add_column :state_file_md_intakes, :paid_extension_payments, :integer, default: 0, null: false
  end
end
