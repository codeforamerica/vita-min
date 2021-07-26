class AddRrcToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :recovery_rebate_credit_amount_1, :integer
    add_column :intakes, :recovery_rebate_credit_amount_2, :integer
    add_column :intakes, :eip1_and_2_amount_received_confidence, :integer
  end
end
