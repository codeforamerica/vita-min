class RenameEipPaymentColumns < ActiveRecord::Migration[6.0]
  def change
    rename_column :intakes, :recovery_rebate_credit_amount_1, :eip1_amount_received
    rename_column :intakes, :recovery_rebate_credit_amount_2, :eip2_amount_received
  end
end
