class AddPaidFederalExtensionPaymentsToStateFileNcIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_nc_intakes, :paid_federal_extension_payments, :integer, default: 0, null: false
  end
end
