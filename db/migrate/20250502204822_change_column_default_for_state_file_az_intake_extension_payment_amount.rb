class ChangeColumnDefaultForStateFileAzIntakeExtensionPaymentAmount < ActiveRecord::Migration[7.1]
  def change
    change_column_default :state_file_az_intakes, :extension_payments_amount, nil
  end
end
