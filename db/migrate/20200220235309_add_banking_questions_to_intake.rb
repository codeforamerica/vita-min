class AddBankingQuestionsToIntake < ActiveRecord::Migration[5.2]
  def change
    add_column :intakes, :refund_payment_method, :integer, default: 0, null: false
    add_column :intakes, :savings_split_refund, :integer, default: 0, null: false
    add_column :intakes, :savings_purchase_bond, :integer, default: 0, null: false
    add_column :intakes, :balance_pay_from_bank, :integer, default: 0, null: false
  end
end
