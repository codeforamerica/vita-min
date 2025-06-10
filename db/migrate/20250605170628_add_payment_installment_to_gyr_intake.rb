class AddPaymentInstallmentToGyrIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :intakes, :payment_in_installments, :integer, default: 0, null: false
  end
end
